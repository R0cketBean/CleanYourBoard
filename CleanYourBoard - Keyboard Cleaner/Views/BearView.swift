//
//  BearView.swift
//  CleanYourBoard - Keyboard Cleaner
//
//  Front-facing bear, scrubbing a keyboard with a brush while the
//  lock is active. Drawn entirely from SwiftUI shapes.
//

import SwiftUI

struct BearView: View {
    enum AnimationState {
        case idle
        case cleaning
    }

    let state: AnimationState

    private let bodyMid    = Color(red: 0.58, green: 0.40, blue: 0.27)
    private let bodyDark   = Color(red: 0.38, green: 0.24, blue: 0.14)
    private let bodyLite   = Color(red: 0.70, green: 0.50, blue: 0.34)
    private let belly      = Color(red: 0.86, green: 0.72, blue: 0.55)
    private let innerEar   = Color(red: 0.92, green: 0.67, blue: 0.58)
    private let muzzle     = Color(red: 0.83, green: 0.66, blue: 0.50)
    private let ink        = Color(red: 0.10, green: 0.07, blue: 0.05)

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let scrubSpeed: Double = 6.0
            let scrub = state == .cleaning ? sin(t * scrubSpeed) : 0
            let bob = state == .cleaning
                ? sin(t * scrubSpeed * 2) * 1.6
                : sin(t * 1.6) * 0.9
            let blink = blinkAmount(time: t)

            ZStack {
                if state == .cleaning {
                    KeyboardSurface()
                        .frame(width: 220, height: 22)
                        .offset(y: 100)
                }

                BearFigure(
                    bodyFill: bodyFill,
                    bodyDark: bodyDark,
                    belly: belly,
                    innerEar: innerEar,
                    muzzle: muzzle,
                    ink: ink,
                    blink: blink,
                    scrub: scrub,
                    showArms: state == .cleaning
                )
                .offset(y: -bob)

                if state == .cleaning {
                    CleaningBrush(scrub: scrub)
                        .offset(x: CGFloat(scrub) * 10, y: 78 - bob * 0.4)

                    SparkleField(time: t)
                        .offset(y: 55)
                        .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityLabel(state == .cleaning
                            ? Text("Bear cleaning the keyboard")
                            : Text("Waiting bear"))
    }

    private var bodyFill: LinearGradient {
        LinearGradient(colors: [bodyLite, bodyMid],
                       startPoint: .top, endPoint: .bottom)
    }

    private func blinkAmount(time t: Double) -> Double {
        let cycle = t.truncatingRemainder(dividingBy: 4.0)
        if cycle > 3.85 {
            return sin((cycle - 3.85) / 0.15 * .pi)
        }
        return 0
    }
}

// MARK: - The bear

private struct BearFigure: View {
    let bodyFill: LinearGradient
    let bodyDark: Color
    let belly: Color
    let innerEar: Color
    let muzzle: Color
    let ink: Color
    let blink: Double
    let scrub: Double
    let showArms: Bool

    var body: some View {
        ZStack {
            // BODY — chunky round body
            Ellipse()
                .fill(bodyFill)
                .frame(width: 150, height: 110)
                .offset(y: 52)
                .shadow(color: .black.opacity(0.18), radius: 8, y: 5)

            // Belly patch
            Ellipse()
                .fill(belly)
                .frame(width: 82, height: 62)
                .offset(y: 62)

            // Arms holding the brush (only while cleaning)
            if showArms {
                Capsule()
                    .fill(bodyFill)
                    .frame(width: 28, height: 60)
                    .rotationEffect(.degrees(32 + scrub * 4))
                    .offset(x: -34 + CGFloat(scrub) * 3, y: 56)
                Capsule()
                    .fill(bodyFill)
                    .frame(width: 28, height: 60)
                    .rotationEffect(.degrees(-32 - scrub * 4))
                    .offset(x: 34 + CGFloat(scrub) * 3, y: 56)
            }

            // HEAD — big round head
            Ellipse()
                .fill(bodyFill)
                .frame(width: 136, height: 122)
                .offset(y: -22)
                .shadow(color: .black.opacity(0.10), radius: 4, y: 2)

            // EARS — big round circles on top of head (the bear hallmark)
            BearEar(outer: bodyDark, inner: innerEar)
                .frame(width: 46, height: 46)
                .offset(x: -48, y: -72)
            BearEar(outer: bodyDark, inner: innerEar)
                .frame(width: 46, height: 46)
                .offset(x: 48, y: -72)

            // MUZZLE — lighter patch on lower face
            Ellipse()
                .fill(muzzle)
                .frame(width: 70, height: 50)
                .offset(y: 5)

            // NOSE — black blob on top of muzzle
            Ellipse()
                .fill(ink)
                .frame(width: 20, height: 14)
                .offset(y: -11)

            // Vertical philtrum line under nose
            Capsule()
                .fill(ink.opacity(0.55))
                .frame(width: 1.5, height: 7)
                .offset(y: -1)

            // MOUTH — smile
            MouthShape()
                .stroke(ink, style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
                .frame(width: 22, height: 8)
                .offset(y: 10)

            // EYES with blink
            BearEye(ink: ink, closeness: blink)
                .frame(width: 12, height: 12)
                .offset(x: -24, y: -30)
            BearEye(ink: ink, closeness: blink)
                .frame(width: 12, height: 12)
                .offset(x: 24, y: -30)
        }
    }
}

// MARK: - Ear / Eye

private struct BearEar: View {
    let outer: Color
    let inner: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(outer)
            Circle()
                .fill(inner)
                .frame(width: 24, height: 24)
                .offset(y: 2)
        }
    }
}

private struct BearEye: View {
    let ink: Color
    let closeness: Double

    var body: some View {
        ZStack {
            Capsule()
                .fill(ink)
                .scaleEffect(x: 1, y: max(0.08, 1.0 - closeness), anchor: .center)

            Circle()
                .fill(.white)
                .frame(width: 3.5, height: 3.5)
                .offset(x: -1.6, y: -1.6)
                .opacity(max(0, 1.0 - closeness * 3))
        }
    }
}

private struct MouthShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let mid = rect.midX
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: mid, y: rect.maxY),
            control: CGPoint(x: (rect.minX + mid) / 2, y: rect.maxY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: (mid + rect.maxX) / 2, y: rect.maxY)
        )
        return path
    }
}

// MARK: - Brush

private struct CleaningBrush: View {
    let scrub: Double

    var body: some View {
        VStack(spacing: -1) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color(red: 0.78, green: 0.55, blue: 0.30),
                             Color(red: 0.55, green: 0.36, blue: 0.18)],
                    startPoint: .top, endPoint: .bottom))
                .frame(width: 64, height: 13)
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(Color.black.opacity(0.18), lineWidth: 0.6)
                )

            HStack(spacing: 1.5) {
                ForEach(0..<10, id: \.self) { _ in
                    Capsule()
                        .fill(LinearGradient(
                            colors: [Color(white: 0.96), Color(white: 0.74)],
                            startPoint: .top, endPoint: .bottom))
                        .frame(width: 3.5, height: 12)
                }
            }
        }
        .rotationEffect(.degrees(scrub * 4))
        .shadow(color: .black.opacity(0.22), radius: 3, y: 2)
    }
}

// MARK: - Keyboard underneath

private struct KeyboardSurface: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(Color.primary.opacity(0.06))
            .overlay(
                HStack(spacing: 2.5) {
                    ForEach(0..<14, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                            .fill(Color.primary.opacity(0.12))
                            .frame(height: 12)
                    }
                }
                .padding(.horizontal, 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(Color.primary.opacity(0.12), lineWidth: 0.7)
            )
    }
}

// MARK: - Sparkles

private struct SparkleField: View {
    let time: Double

    private static let seeds: [(CGPoint, Double)] = [
        (CGPoint(x: -36, y: -4), 0.0),
        (CGPoint(x: 30, y: 6),   0.7),
        (CGPoint(x: -6, y: 14),  1.4),
        (CGPoint(x: 20, y: -10), 2.0),
        (CGPoint(x: -18, y: -2), 2.5)
    ]

    var body: some View {
        ZStack {
            ForEach(Array(Self.seeds.enumerated()), id: \.offset) { _, item in
                SparkleDot(time: time, phaseOffset: item.1)
                    .position(x: 110 + item.0.x, y: 30 + item.0.y)
            }
        }
        .frame(width: 220, height: 60)
    }
}

private struct SparkleDot: View {
    let time: Double
    let phaseOffset: Double

    var body: some View {
        let period: Double = 1.8
        let local = (time + phaseOffset).truncatingRemainder(dividingBy: period) / period
        let opacity = sin(local * .pi)
        let scale = 0.5 + sin(local * .pi) * 0.6

        Image(systemName: "sparkle")
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(.tint.opacity(opacity * 0.9))
            .scaleEffect(scale)
    }
}

#Preview("Cleaning – Light") {
    BearView(state: .cleaning)
        .frame(width: 280, height: 220)
        .padding(40)
        .background(Color(nsColor: .windowBackgroundColor))
        .preferredColorScheme(.light)
}

#Preview("Cleaning – Dark") {
    BearView(state: .cleaning)
        .frame(width: 280, height: 220)
        .padding(40)
        .background(Color(nsColor: .windowBackgroundColor))
        .preferredColorScheme(.dark)
}

#Preview("Idle") {
    BearView(state: .idle)
        .frame(width: 280, height: 220)
        .padding(40)
        .background(Color(nsColor: .windowBackgroundColor))
}
