//
//  KeyboardLockManager.swift
//  CleanYourBoard - Keyboard Cleaner
//

import AppKit
import ApplicationServices
import Combine
import CoreGraphics
import IOKit.pwr_mgt
import Observation

private let kEscapeKeyCode: Int64 = 53
private let kSystemDefinedEventType: UInt32 = 14

@MainActor
@Observable
final class KeyboardLockManager {

    enum LockError: LocalizedError {
        case noAccessibility
        case tapCreationFailed

        var errorDescription: String? {
            switch self {
            case .noAccessibility:
                return String(localized: "Accessibility permission missing.")
            case .tapCreationFailed:
                return String(localized: "Could not create keyboard event tap.")
            }
        }
    }

    private(set) var isLocked = false
    private(set) var hasAccessibilityPermission = false
    private(set) var lastError: LockError?

    var unlockProgress: Double = 0.0

    private let unlockHoldDuration: TimeInterval = 3.0

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var escHeldSince: Date?
    private var progressTask: Task<Void, Never>?
    private var displayWakeAssertion: IOPMAssertionID?

    init() {
        refreshAccessibilityState()
    }

    func refreshAccessibilityState() {
        hasAccessibilityPermission = AXIsProcessTrusted()
    }

    func promptForAccessibility() {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let opts = [key: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(opts)
        refreshAccessibilityState()
    }

    func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
        if let url {
            NSWorkspace.shared.open(url)
        }
    }

    @discardableResult
    func lock() -> Bool {
        guard !isLocked else { return true }
        refreshAccessibilityState()
        guard hasAccessibilityPermission else {
            lastError = .noAccessibility
            promptForAccessibility()
            return false
        }
        guard installEventTap() else {
            lastError = .tapCreationFailed
            return false
        }
        acquireDisplayWakeAssertion()
        lastError = nil
        isLocked = true
        return true
    }

    func unlock() {
        guard isLocked else { return }
        uninstallEventTap()
        releaseDisplayWakeAssertion()
        cancelUnlockProgress()
        isLocked = false

        // Increment lifetime unlock counter — used by the rating prompt
        // to decide when to ask the user to star the repo.
        let key = "totalUnlocks"
        let current = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(current + 1, forKey: key)
    }

    func toggle() {
        if isLocked {
            unlock()
        } else {
            _ = lock()
        }
    }

    fileprivate func handleTapEvent(type: CGEventType, event: CGEvent) {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap = eventTap {
                CGEvent.tapEnable(tap: tap, enable: true)
            }
            return
        }

        // Only keyDown / keyUp carry a key code; system-defined events bypass this.
        guard type == .keyDown || type == .keyUp else { return }
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        guard keyCode == kEscapeKeyCode else { return }

        if type == .keyDown {
            let isRepeat = event.getIntegerValueField(.keyboardEventAutorepeat) != 0
            if !isRepeat && escHeldSince == nil {
                escHeldSince = Date()
                startProgressTimer()
            }
        } else {
            cancelUnlockProgress()
        }
    }

    private func installEventTap() -> Bool {
        let mask: CGEventMask =
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue) |
            (1 << CGEventType.flagsChanged.rawValue) |
            (CGEventMask(1) << CGEventMask(kSystemDefinedEventType))

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        let callback: CGEventTapCallBack = { _, type, event, userInfo in
            guard let userInfo else { return Unmanaged.passUnretained(event) }
            let manager = Unmanaged<KeyboardLockManager>.fromOpaque(userInfo).takeUnretainedValue()
            MainActor.assumeIsolated {
                manager.handleTapEvent(type: type, event: event)
            }
            // Suppress every captured event while locked.
            return nil
        }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: selfPtr
        ) else {
            return false
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        eventTap = tap
        runLoopSource = source
        return true
    }

    private func uninstallEventTap() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
    }

    private func startProgressTimer() {
        progressTask?.cancel()
        progressTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(33))
                guard !Task.isCancelled, let self else { return }
                self.tickUnlockProgress()
            }
        }
    }

    private func tickUnlockProgress() {
        guard let since = escHeldSince else {
            unlockProgress = 0
            return
        }
        let elapsed = Date().timeIntervalSince(since)
        let progress = min(elapsed / unlockHoldDuration, 1.0)
        unlockProgress = progress
        if progress >= 1.0 {
            unlock()
        }
    }

    private func cancelUnlockProgress() {
        escHeldSince = nil
        unlockProgress = 0
        progressTask?.cancel()
        progressTask = nil
    }

    // MARK: - Display wake assertion

    /// Prevents the display from idle-sleeping while the keyboard is locked,
    /// so a thorough wipe-down doesn't leave the user staring at a black screen.
    private func acquireDisplayWakeAssertion() {
        releaseDisplayWakeAssertion()
        var assertionID: IOPMAssertionID = 0
        let reason = "CleanYourBoard is blocking the keyboard for cleaning." as CFString
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )
        if result == kIOReturnSuccess {
            displayWakeAssertion = assertionID
        }
    }

    private func releaseDisplayWakeAssertion() {
        guard let id = displayWakeAssertion else { return }
        IOPMAssertionRelease(id)
        displayWakeAssertion = nil
    }
}
