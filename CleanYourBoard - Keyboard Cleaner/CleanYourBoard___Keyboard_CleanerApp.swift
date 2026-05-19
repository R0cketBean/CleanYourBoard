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
        // Resolve the language override BEFORE SwiftUI loads any string resources.
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
    }
}
