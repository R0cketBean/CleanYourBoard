//
//  RatingPromptSheet.swift
//  CleanYourBoard - Keyboard Cleaner
//

import SwiftUI

struct RatingPromptSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let repoURL = URL(string: "https://github.com/R0cketBean/CleanYourBoard")!

    var body: some View {
        VStack(spacing: 22) {
            // Star with halo — sits at the optical centre of the sheet.
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.18))
                    .frame(width: 96, height: 96)

                Image(systemName: "star.fill")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.yellow)
                    .offset(y: -1) // optical centre nudge for the star glyph
            }

            VStack(spacing: 6) {
                Text("Enjoying CleanYourBoard?")
                    .font(.system(.title2, design: .rounded, weight: .semibold))
                    .multilineTextAlignment(.center)

                Text("A GitHub star helps others find the app.")
                    .font(.system(.callout, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 8) {
                Button {
                    openURL(repoURL)
                    dismiss()
                } label: {
                    Text("Star on GitHub")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)

                Button {
                    dismiss()
                } label: {
                    Text("No thanks")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(28)
        .frame(width: 340)
    }
}

#Preview {
    RatingPromptSheet()
}
