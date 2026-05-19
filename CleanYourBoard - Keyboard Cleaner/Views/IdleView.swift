//
//  IdleView.swift
//  CleanYourBoard - Keyboard Cleaner
//

import SwiftUI

struct IdleView: View {
    @Environment(KeyboardLockManager.self) private var lockManager

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 6) {
                Text("CleanYourBoard")
                    .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("Lock the keyboard, clean it in peace.")
                    .font(.system(.callout, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            BearView(state: .idle)
                .frame(width: 260, height: 220)

            Button {
                lockManager.toggle()
            } label: {
                Label("Lock keyboard", systemImage: "lock.fill")
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .keyboardShortcut(.defaultAction)

            if let error = lockManager.lastError {
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 340)
            }

            HintRow()
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity)
    }
}

private struct HintRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HintLine(symbol: "keyboard.fill",
                     text: "All keys, including F1–F12, are blocked.")
            HintLine(symbol: "computermouse.fill",
                     text: "Mouse stays usable—unlock anytime.")
            HintLine(symbol: "escape",
                     text: "Holding Esc for 3 seconds also unlocks.")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: 360)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.separator, lineWidth: 0.5)
        )
    }
}

private struct HintLine: View {
    let symbol: String
    let text: LocalizedStringKey

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .frame(width: 18)
                .foregroundStyle(.secondary)
            Text(text)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.primary)
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    IdleView()
        .environment(KeyboardLockManager())
        .frame(width: 460, height: 560)
        .padding(28)
        .background(Color(nsColor: .windowBackgroundColor))
}
