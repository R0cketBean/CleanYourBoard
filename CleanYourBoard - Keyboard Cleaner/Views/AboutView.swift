//
//  AboutView.swift
//  CleanYourBoard - Keyboard Cleaner
//

import SwiftUI

struct AboutView: View {
    @Environment(UpdaterController.self) private var updater
    @Environment(\.openURL) private var openURL

    private let repoURL = URL(string: "https://github.com/R0cketBean/CleanYourBoard")!
    private let privacyURL = URL(string: "https://github.com/R0cketBean/CleanYourBoard/blob/main/PRIVACY.md")!

    var body: some View {
        VStack(spacing: 18) {
            iconView
                .frame(width: 96, height: 96)

            VStack(spacing: 4) {
                Text("CleanYourBoard")
                    .font(.system(.title, design: .rounded, weight: .semibold))
                Text(versionLine)
                    .font(.system(.callout, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Text("Lock the keyboard, clean it in peace.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)

            Divider().padding(.horizontal, 32)

            VStack(spacing: 8) {
                if updater.isAvailable {
                    Button {
                        updater.checkForUpdates()
                    } label: {
                        Label("Check for updates", systemImage: "arrow.down.circle")
                            .frame(minWidth: 200)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!updater.canCheckForUpdates)
                }

                HStack(spacing: 10) {
                    Button {
                        openURL(repoURL)
                    } label: {
                        Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                    Button {
                        openURL(privacyURL)
                    } label: {
                        Label("Privacy", systemImage: "hand.raised.fill")
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }

            Text(AppCredits.copyrightLine)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding(28)
        .frame(width: 380)
    }

    private var iconView: some View {
        Group {
            if let nsImage = NSApp.applicationIconImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.accentColor.opacity(0.15))
                    .overlay(
                        Image(systemName: "lock.fill")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(.tint)
                    )
            }
        }
    }

    private var versionLine: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return String(localized: "Version \(short) (\(build))")
    }
}

#Preview("Light") {
    AboutView()
        .environment(UpdaterController())
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    AboutView()
        .environment(UpdaterController())
        .preferredColorScheme(.dark)
}
