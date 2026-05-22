//
//  ContentView.swift
//  CleanYourBoard - Keyboard Cleaner
//

import SwiftUI

struct ContentView: View {
    @Environment(KeyboardLockManager.self) private var lockManager
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openSettings) private var openSettings

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
        .animation(.smooth(duration: 0.4), value: lockManager.isLocked)
        .animation(.smooth(duration: 0.3), value: lockManager.hasAccessibilityPermission)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                lockManager.refreshAccessibilityState()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    openSettings()
                } label: {
                    Label("Settings…", systemImage: "gearshape")
                }
                .help(String(localized: "Settings…"))
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(KeyboardLockManager())
        .frame(width: 460, height: 560)
}
