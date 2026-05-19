//
//  AppLanguage.swift
//  CleanYourBoard - Keyboard Cleaner
//

import AppKit
import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case en
    case de
    case fr
    case es
    case it
    case ja
    case zhHans = "zh-Hans"

    var id: String { rawValue }

    /// The locale identifier macOS uses in the `AppleLanguages` user-defaults override.
    /// `nil` means "follow system language".
    var localeIdentifier: String? {
        switch self {
        case .system: nil
        case .en: "en"
        case .de: "de"
        case .fr: "fr"
        case .es: "es"
        case .it: "it"
        case .ja: "ja"
        case .zhHans: "zh-Hans"
        }
    }

    /// Native display name — always rendered in the language itself so users can
    /// recognise their language even when the app is currently in another.
    var displayName: String {
        switch self {
        case .system: String(localized: "System")
        case .en: "English"
        case .de: "Deutsch"
        case .fr: "Français"
        case .es: "Español"
        case .it: "Italiano"
        case .ja: "日本語"
        case .zhHans: "简体中文"
        }
    }

    /// Compact label used in the toolbar trigger — fits next to the globe icon
    /// without making the toolbar feel crowded.
    var shortLabel: String {
        switch self {
        case .system: String(localized: "System")
        case .en: "English"
        case .de: "Deutsch"
        case .fr: "Français"
        case .es: "Español"
        case .it: "Italiano"
        case .ja: "日本語"
        case .zhHans: "中文"
        }
    }
}

@MainActor
enum LanguageOverride {
    static let userDefaultsKey = "appLanguage"
    private static let appleLanguagesKey = "AppleLanguages"

    /// Apply the user's stored preference into `AppleLanguages` so the next
    /// app launch resolves resources in that locale.
    static func applyStoredPreference() {
        let raw = UserDefaults.standard.string(forKey: userDefaultsKey) ?? AppLanguage.system.rawValue
        let lang = AppLanguage(rawValue: raw) ?? .system
        if let id = lang.localeIdentifier {
            UserDefaults.standard.set([id], forKey: appleLanguagesKey)
        } else {
            UserDefaults.standard.removeObject(forKey: appleLanguagesKey)
        }
    }

    /// Re-launch the app so localized resources are reloaded in the new language.
    static func relaunch() {
        guard let bundlePath = Bundle.main.bundlePath as String?,
              !bundlePath.isEmpty else { return }

        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-n", bundlePath]
        try? task.run()

        // Give `open` a moment to spawn the new instance before we terminate.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            NSApp.terminate(nil)
        }
    }
}
