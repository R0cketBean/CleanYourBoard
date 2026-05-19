//
//  AccessibilityRequestView.swift
//  CleanYourBoard - Keyboard Cleaner
//

import SwiftUI

struct AccessibilityRequestView: View {
    @Environment(KeyboardLockManager.self) private var lockManager

    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: 6) {
                Text("Accessibility access required")
                    .font(.system(.title2, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("To safely block all keys—including F1–F12—CleanYourBoard needs access to Accessibility.")
                    .font(.system(.callout, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 380)
            }

            VStack(alignment: .leading, spacing: 12) {
                StepRow(number: "1", text: "Click »Open Settings«.")
                StepRow(number: "2", text: "Enable CleanYourBoard in the list.")
                StepRow(number: "3", text: "Return here and tap »Re-check«.")
            }
            .padding(16)
            .frame(maxWidth: 380)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.separator, lineWidth: 0.5)
            )

            VStack(spacing: 10) {
                Button {
                    lockManager.openAccessibilitySettings()
                    lockManager.promptForAccessibility()
                } label: {
                    Label("Open Settings", systemImage: "gearshape.fill")
                }
                .buttonStyle(PrimaryActionButtonStyle())

                Button {
                    lockManager.refreshAccessibilityState()
                } label: {
                    Label("Re-check", systemImage: "arrow.clockwise")
                }
                .buttonStyle(SecondaryActionButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity)
    }
}

private struct StepRow: View {
    let number: String
    let text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color.accentColor))
            Text(text)
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(.primary)
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    AccessibilityRequestView()
        .environment(KeyboardLockManager())
        .frame(width: 460, height: 560)
        .padding(28)
        .background(Color(nsColor: .windowBackgroundColor))
}
