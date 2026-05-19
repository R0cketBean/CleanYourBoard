//
//  LockedView.swift
//  CleanYourBoard - Keyboard Cleaner
//

import SwiftUI

struct LockedView: View {
    @Environment(KeyboardLockManager.self) private var lockManager

    private var isHolding: Bool { lockManager.unlockProgress > 0.02 }

    var body: some View {
        VStack(spacing: 24) {
            LockBadge()

            ZStack {
                UnlockProgressRing(progress: lockManager.unlockProgress)
                    .frame(width: 300, height: 300)

                BearView(state: .cleaning)
                    .frame(width: 260, height: 220)
            }

            VStack(spacing: 12) {
                Group {
                    if isHolding {
                        Text(lockManager.unlockProgress, format: .percent.precision(.fractionLength(0)))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())
                    } else {
                        Text("Hold Esc for 3 seconds to unlock")
                            .font(.system(.title3, design: .rounded, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .animation(.smooth(duration: 0.2), value: isHolding)
                .frame(minHeight: 52)

                Button {
                    lockManager.unlock()
                } label: {
                    Label("Unlock", systemImage: "lock.open.fill")
                }
                .buttonStyle(SecondaryActionButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity)
    }
}

private struct LockBadge: View {
    var body: some View {
        Label("Keyboard locked", systemImage: "lock.fill")
            .font(.system(.callout, design: .rounded, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(Color.accentColor)
            )
            .shadow(color: Color.accentColor.opacity(0.35), radius: 8, y: 3)
    }
}

#Preview {
    LockedView()
        .environment(KeyboardLockManager())
        .frame(width: 460, height: 600)
        .padding(28)
        .background(Color(nsColor: .windowBackgroundColor))
}
