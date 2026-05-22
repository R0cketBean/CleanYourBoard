//
//  CleanYourBoard___Keyboard_CleanerApp.swift
//  CleanYourBoard - Keyboard Cleaner
//

import SwiftUI

@main
struct CleanYourBoardApp: App {
    @State private var lockManager: KeyboardLockManager
    @State private var updater: UpdaterController
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system

    @Environment(\.openWindow) private var openWindow

    init() {
        LanguageOverride.applyStoredPreference()
        _lockManager = State(initialValue: KeyboardLockManager())
        _updater = State(initialValue: UpdaterController())
    }

    var body: some Scene {
        Window("CleanYourBoard", id: "main") {
            ContentView()
                .environment(lockManager)
                .environment(updater)
                .preferredColorScheme(appearanceMode.colorScheme)
                .frame(minWidth: 460, minHeight: 560)
        }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandGroup(replacing: .appInfo) {
                Button("About CleanYourBoard") {
                    openWindow(id: "about")
                }
            }
        }

        Window("About CleanYourBoard", id: "about") {
            AboutView()
                .environment(updater)
                .preferredColorScheme(appearanceMode.colorScheme)
        }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultPosition(.center)

        Settings {
            SettingsView()
                .environment(updater)
                .preferredColorScheme(appearanceMode.colorScheme)
        }

        MenuBarExtra {
            MenuBarContent()
                .environment(lockManager)
        } label: {
            Image(systemName: lockManager.isLocked ? "lock.fill" : "lock.open")
        }
        .menuBarExtraStyle(.menu)
    }
}

// MARK: - Menubar menu

private struct MenuBarContent: View {
    @Environment(KeyboardLockManager.self) private var lockManager
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        if lockManager.isLocked {
            Text("Keyboard locked")
            Button("Unlock keyboard") { lockManager.unlock() }
                .keyboardShortcut("l", modifiers: [.command, .shift])
        } else if lockManager.hasAccessibilityPermission {
            Text("Keyboard unlocked")
            Button("Lock keyboard") { _ = lockManager.lock() }
                .keyboardShortcut("l", modifiers: [.command, .shift])
        } else {
            Text("Accessibility access required")
        }

        Divider()

        Button("Show window") {
            openWindow(id: "main")
            NSApp.activate(ignoringOtherApps: true)
        }

        SettingsLink {
            Text("Settings…")
        }

        Divider()

        Button("Quit CleanYourBoard") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: [.command])
    }
}
