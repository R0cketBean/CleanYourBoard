//
//  SettingsView.swift
//  CleanYourBoard - Keyboard Cleaner
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsTab()
                .tabItem { Label("General", systemImage: "gearshape") }

            AppearanceSettingsTab()
                .tabItem { Label("Appearance", systemImage: "paintpalette") }

            UpdatesSettingsTab()
                .tabItem { Label("Updates", systemImage: "arrow.down.circle") }
        }
        .frame(width: 460, height: 280)
    }
}

// MARK: - General

private struct GeneralSettingsTab: View {
    @AppStorage(LanguageOverride.userDefaultsKey) private var appLanguage: AppLanguage = .system
    @State private var pendingLanguage: AppLanguage?

    var body: some View {
        Form {
            Section {
                Picker("Language", selection: Binding(
                    get: { appLanguage },
                    set: { newValue in
                        guard newValue != appLanguage else { return }
                        appLanguage = newValue
                        pendingLanguage = newValue
                    }
                )) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .pickerStyle(.menu)
            } footer: {
                Text("Changing the language requires CleanYourBoard to restart.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
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

// MARK: - Appearance

private struct AppearanceSettingsTab: View {
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system

    var body: some View {
        Form {
            Section {
                Picker("Appearance", selection: $appearanceMode) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Label(mode.label, systemImage: mode.systemImage).tag(mode)
                    }
                }
                .pickerStyle(.inline)
            } footer: {
                Text("Match the system setting or pick light or dark explicitly.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Updates

private struct UpdatesSettingsTab: View {
    @Environment(UpdaterController.self) private var updater
    @AppStorage("SUEnableAutomaticChecks") private var autoCheckEnabled: Bool = true
    @AppStorage("SUAutomaticallyUpdate") private var autoInstallEnabled: Bool = false

    var body: some View {
        Form {
            Section {
                Toggle("Automatically check for updates", isOn: $autoCheckEnabled)
                Toggle("Automatically download and install updates", isOn: $autoInstallEnabled)
                    .disabled(!autoCheckEnabled)
            } footer: {
                Text("CleanYourBoard checks the official update feed; no other data is sent.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if updater.isAvailable {
                Section {
                    HStack {
                        Spacer()
                        Button {
                            updater.checkForUpdates()
                        } label: {
                            Label("Check now", systemImage: "arrow.down.circle")
                                .frame(minWidth: 160)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(!updater.canCheckForUpdates)
                        Spacer()
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}

#Preview("Light") {
    SettingsView()
        .environment(UpdaterController())
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SettingsView()
        .environment(UpdaterController())
        .preferredColorScheme(.dark)
}
