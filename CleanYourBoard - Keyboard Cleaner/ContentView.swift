//
//  ContentView.swift
//  CleanYourBoard - Keyboard Cleaner
//

import SwiftUI

struct ContentView: View {
    @Environment(KeyboardLockManager.self) private var lockManager
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    @AppStorage(LanguageOverride.userDefaultsKey) private var appLanguage: AppLanguage = .system

    @State private var pendingLanguage: AppLanguage?

    var body: some View {
        Group {
            if !lockManager.hasAccessibilityPermission && !lockManager.isLocked {
                AccessibilityRequestView()
            } else if lockManager.isLocked {
                LockedView()
            } else {
                IdleView()
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .animation(.smooth(duration: 0.4), value: lockManager.isLocked)
        .animation(.smooth(duration: 0.3), value: lockManager.hasAccessibilityPermission)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                lockManager.refreshAccessibilityState()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                LanguageMenu(selection: $appLanguage, pendingLanguage: $pendingLanguage)
            }
            ToolbarItem(placement: .primaryAction) {
                AppearancePicker(selection: $appearanceMode)
            }
        }
        .alert(
            Text("Restart required"),
            isPresented: Binding(
                get: { pendingLanguage != nil },
                set: { if !$0 { pendingLanguage = nil } }
            ),
            presenting: pendingLanguage
        ) { _ in
            Button("Restart now", role: .destructive) {
                LanguageOverride.applyStoredPreference()
                LanguageOverride.relaunch()
            }
            Button("Later", role: .cancel) {
                pendingLanguage = nil
            }
        } message: { lang in
            Text("CleanYourBoard needs to restart to switch the language to \(lang.displayName).")
        }
    }
}

// MARK: - Toolbar controls

private struct AppearancePicker: View {
    @Binding var selection: AppearanceMode

    var body: some View {
        Picker(selection: $selection) {
            ForEach(AppearanceMode.allCases) { mode in
                Image(systemName: mode.systemImage)
                    .help(mode.label)
                    .tag(mode)
            }
        } label: {
            Text("Appearance")
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .fixedSize()
        .help(String(localized: "Appearance: \(selection.label)"))
    }
}

private struct LanguageMenu: View {
    @Binding var selection: AppLanguage
    @Binding var pendingLanguage: AppLanguage?

    var body: some View {
        Menu {
            Picker(selection: Binding(
                get: { selection },
                set: { newValue in
                    guard newValue != selection else { return }
                    selection = newValue
                    pendingLanguage = newValue
                }
            )) {
                ForEach(AppLanguage.allCases) { lang in
                    Text(lang.displayName).tag(lang)
                }
            } label: {
                Text("Language")
            }
            .pickerStyle(.inline)
        } label: {
            Label {
                Text(selection.shortLabel)
            } icon: {
                Image(systemName: "globe")
            }
        }
        .menuStyle(.button)
        .buttonStyle(.bordered)
        .controlSize(.large)
        .fixedSize()
        .help(String(localized: "Language: \(selection.displayName)"))
    }
}

#Preview {
    ContentView()
        .environment(KeyboardLockManager())
        .frame(width: 460, height: 560)
}
