// GenerateAppIcon.swift
// Run with:  swift Scripts/GenerateAppIcon.swift
// Renders the app icon (bear on accent-coloured rounded square) at 1024×1024
// and uses `sips` to derive every size needed for AppIcon.appiconset.

import SwiftUI
import AppKit

// MARK: - Icon design

struct AppIconView: View {
    var body: some View {
        ZStack {
            // Rounded-square body with a light-blue sky gradient
            RoundedRectangle(cornerRadius: 185, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.34, green: 0.62, blue: 0.88),
                            Color(red: 0.66, green: 0.84, blue: 0.96)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 824, height: 824)
                .overlay(
                    RoundedRectangle(cornerRadius: 185, style: .continuous)
                        .stroke(.white.opacity(0.25), lineWidth: 4)
                        .frame(width: 824, height: 824)
                )
                .shadow(color: .black.opacity(0.22), radius: 30, y: 18)

            // Background twinkles
            Group {
                Image(systemName: "sparkle")
                    .font(.system(size: 90, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
                    .offset(x: -260, y: -260)

                Image(systemName: "sparkle")
                    .font(.system(size: 60, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.4))
                    .offset(x: 260, y: 260)

                Image(systemName: "sparkle")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .offset(x: 290, y: -190)
            }

            // Bear face
            IconBearFace()
                .frame(width: 560, height: 540)
                .offset(y: 18)
        }
        .frame(width: 1024, height: 1024)
        .background(Color.clear)
    }
}

private struct IconBearFace: View {
    // Matches the in-app BearView colour palette.
    private let bodyMid  = Color(red: 0.58, green: 0.40, blue: 0.27)
    private let bodyDark = Color(red: 0.38, green: 0.24, blue: 0.14)
    private let bodyLite = Color(red: 0.70, green: 0.50, blue: 0.34)
    private let muzzle   = Color(red: 0.83, green: 0.66, blue: 0.50)
    private let innerEar = Color(red: 0.92, green: 0.67, blue: 0.58)
    private let ink      = Color(red: 0.10, green: 0.07, blue: 0.05)

    private var fill: LinearGradient {
        LinearGradient(colors: [bodyLite, bodyMid], startPoint: .top, endPoint: .bottom)
    }

    var body: some View {
        ZStack {
            // Ears (outer)
            Circle().fill(fill).frame(width: 200, height: 200).offset(x: -190, y: -200)
            Circle().fill(fill).frame(width: 200, height: 200).offset(x: 190, y: -200)

            // Ears (inner)
            Circle().fill(innerEar).frame(width: 110, height: 110).offset(x: -190, y: -185)
            Circle().fill(innerEar).frame(width: 110, height: 110).offset(x: 190, y: -185)

            // Head
            Ellipse().fill(fill).frame(width: 560, height: 500).offset(y: -10)

            // Cheek blush for warmth
            Circle().fill(Color(red: 1.0, green: 0.65, blue: 0.55).opacity(0.35))
                .frame(width: 80, height: 60).offset(x: -180, y: 70)
            Circle().fill(Color(red: 1.0, green: 0.65, blue: 0.55).opacity(0.35))
                .frame(width: 80, height: 60).offset(x: 180, y: 70)

            // Muzzle
            Ellipse().fill(muzzle).frame(width: 280, height: 200).offset(y: 75)

            // Nose
            Ellipse().fill(ink).frame(width: 80, height: 56).offset(y: 5)

            // Philtrum line
            Capsule().fill(ink.opacity(0.6)).frame(width: 6, height: 38).offset(y: 50)

            // Mouth
            BearMouthShape()
                .stroke(ink, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .frame(width: 100, height: 38)
                .offset(y: 100)

            // Eyes
            Capsule().fill(ink).frame(width: 44, height: 50).offset(x: -100, y: -40)
            Capsule().fill(ink).frame(width: 44, height: 50).offset(x: 100, y: -40)
            // Eye highlights
            Circle().fill(.white).frame(width: 14, height: 14).offset(x: -107, y: -50)
            Circle().fill(.white).frame(width: 14, height: 14).offset(x: 93, y: -50)
        }
    }
}

private struct BearMouthShape: Shape {
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

// MARK: - Renderer

@MainActor
func renderMaster(to url: URL) -> Bool {
    let renderer = ImageRenderer(content: AppIconView())
    renderer.proposedSize = ProposedViewSize(width: 1024, height: 1024)
    renderer.scale = 1.0
    renderer.isOpaque = false

    guard let image = renderer.nsImage else {
        print("Render failed: ImageRenderer produced no image")
        return false
    }

    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        print("PNG conversion failed")
        return false
    }

    do {
        try png.write(to: url)
        return true
    } catch {
        print("Write failed: \(error)")
        return false
    }
}

// MARK: - Entry point

let scriptURL = URL(fileURLWithPath: CommandLine.arguments[0])
let scriptDir = scriptURL.deletingLastPathComponent()
let projectDir = scriptDir.deletingLastPathComponent()
let appiconsetDir = projectDir
    .appendingPathComponent("CleanYourBoard - Keyboard Cleaner")
    .appendingPathComponent("Assets.xcassets")
    .appendingPathComponent("AppIcon.appiconset")

let masterURL = appiconsetDir.appendingPathComponent("icon_1024.png")

let succeeded = MainActor.assumeIsolated {
    renderMaster(to: masterURL)
}

guard succeeded else { exit(1) }
print("✓ Master rendered: \(masterURL.path)")

// Define every output the .appiconset Contents.json expects
struct IconVariant {
    let filename: String
    let pixelSize: Int
}

let variants: [IconVariant] = [
    .init(filename: "icon_16.png",    pixelSize: 16),
    .init(filename: "icon_16@2x.png", pixelSize: 32),
    .init(filename: "icon_32.png",    pixelSize: 32),
    .init(filename: "icon_32@2x.png", pixelSize: 64),
    .init(filename: "icon_128.png",   pixelSize: 128),
    .init(filename: "icon_128@2x.png", pixelSize: 256),
    .init(filename: "icon_256.png",   pixelSize: 256),
    .init(filename: "icon_256@2x.png", pixelSize: 512),
    .init(filename: "icon_512.png",   pixelSize: 512),
    .init(filename: "icon_512@2x.png", pixelSize: 1024),
]

for v in variants {
    let outURL = appiconsetDir.appendingPathComponent(v.filename)
    let task = Process()
    task.launchPath = "/usr/bin/sips"
    task.arguments = ["-z", "\(v.pixelSize)", "\(v.pixelSize)",
                      masterURL.path, "--out", outURL.path]
    task.standardOutput = Pipe()
    task.standardError = Pipe()
    do {
        try task.run()
        task.waitUntilExit()
        guard task.terminationStatus == 0 else {
            print("sips failed for \(v.filename)")
            exit(2)
        }
        print("✓ \(v.filename) (\(v.pixelSize)×\(v.pixelSize))")
    } catch {
        print("sips launch failed: \(error)")
        exit(3)
    }
}

// Remove master since it's not referenced by Contents.json
try? FileManager.default.removeItem(at: masterURL)

print("✓ All icon variants written to \(appiconsetDir.lastPathComponent)")
