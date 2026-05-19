//
//  PrimaryActionButtonStyle.swift
//  CleanYourBoard - Keyboard Cleaner
//

import SwiftUI

struct PrimaryActionButtonStyle: ButtonStyle {
    var minWidth: CGFloat = 240

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.title3, design: .rounded, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .frame(minWidth: minWidth)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.accentColor.gradient)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color.accentColor.opacity(configuration.isPressed ? 0.20 : 0.38),
                    radius: configuration.isPressed ? 6 : 14,
                    x: 0, y: configuration.isPressed ? 2 : 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(duration: 0.22), value: configuration.isPressed)
            .contentShape(Capsule())
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    var minWidth: CGFloat = 180

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .rounded, weight: .medium))
            .foregroundStyle(.primary)
            .padding(.horizontal, 24)
            .padding(.vertical, 11)
            .frame(minWidth: minWidth)
            .background(
                Capsule(style: .continuous)
                    .fill(.regularMaterial)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(.separator, lineWidth: 0.6)
            )
            .shadow(color: .black.opacity(configuration.isPressed ? 0.04 : 0.08),
                    radius: configuration.isPressed ? 2 : 6, y: 3)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(duration: 0.22), value: configuration.isPressed)
            .contentShape(Capsule())
    }
}
