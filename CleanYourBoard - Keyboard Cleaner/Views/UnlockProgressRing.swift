//
//  UnlockProgressRing.swift
//  CleanYourBoard - Keyboard Cleaner
//

import SwiftUI

struct UnlockProgressRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 8)

            Circle()
                .trim(from: 0, to: max(0.001, progress))
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.smooth(duration: 0.15), value: progress)
                .shadow(color: Color.accentColor.opacity(progress > 0 ? 0.45 : 0),
                        radius: 10)
        }
    }
}

#Preview("Light – 0 %") {
    UnlockProgressRing(progress: 0)
        .frame(width: 280, height: 280)
        .padding(40)
        .background(Color(nsColor: .windowBackgroundColor))
        .preferredColorScheme(.light)
}

#Preview("Light – 60 %") {
    UnlockProgressRing(progress: 0.6)
        .frame(width: 280, height: 280)
        .padding(40)
        .background(Color(nsColor: .windowBackgroundColor))
        .preferredColorScheme(.light)
}

#Preview("Dark – 60 %") {
    UnlockProgressRing(progress: 0.6)
        .frame(width: 280, height: 280)
        .padding(40)
        .background(Color(nsColor: .windowBackgroundColor))
        .preferredColorScheme(.dark)
}
