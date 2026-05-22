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
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.15))
                    .frame(width: 88, height: 88)
                Image(systemName: "star.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(.yellow)
            }
            .padding(.top, 8)

            VStack(spacing: 8) {
                Text("Enjoying CleanYourBoard?")
                    .font(.system(.title2, design: .rounded, weight: .semibold))
                    .multilineTextAlignment(.center)

                Text("A GitHub star helps others find the app.")
                    .font(.system(.callout, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                Button {
                    openURL(repoURL)
                    dismiss()
                } label: {
                    Label("Star on GitHub", systemImage: "star")
                }
                .buttonStyle(PrimaryActionButtonStyle())

                Button("No thanks") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .padding(28)
        .frame(width: 360)
    }
}

#Preview {
    RatingPromptSheet()
        .frame(height: 380)
}
