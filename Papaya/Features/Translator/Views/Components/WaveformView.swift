//
//  WaveformView.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 28.02.26.
//

import SwiftUI

/// A native animated waveform that replaces the Lottie dependency.
/// Uses TimelineView + Canvas to draw smooth, oscillating sine waves
/// that respond to the recording state.
struct WaveformView: View {
    var isAnimating: Bool

    // The number of overlapping sine waves to draw for a richer effect.
    private let waveCount = 3
    // Base amplitude when animating, as a fraction of the view height.
    private let baseAmplitude: CGFloat = 0.3

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            Canvas { context, size in
                let midY = size.height / 2
                let width = size.width

                // Use the timeline date to drive continuous animation.
                let time = timeline.date.timeIntervalSinceReferenceDate

                for wave in 0..<waveCount {
                    let waveOffset = Double(wave)
                    // Each wave has a slightly different frequency and phase for visual richness.
                    let frequency: Double = 3.0 + waveOffset * 0.8
                    let phaseShift = time * (2.5 + waveOffset * 0.6) + waveOffset * 0.8
                    // Vary amplitude per wave and apply a smooth decay when not animating.
                    let amplitude = isAnimating
                        ? baseAmplitude * size.height * (1.0 - CGFloat(wave) * 0.25)
                        : 0

                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: midY))

                    // Draw the sine wave point by point across the width.
                    for x in stride(from: 0, through: width, by: 2) {
                        let relativeX = x / width
                        // A bell-curve envelope so the wave tapers at the edges.
                        let envelope = sin(.pi * relativeX)
                        let y = midY + amplitude * envelope * sin(frequency * .pi * relativeX + phaseShift)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }

                    // Each wave gets progressively more transparent.
                    let opacity = 0.8 - Double(wave) * 0.25
                    context.stroke(
                        path,
                        with: .color(.white.opacity(opacity)),
                        lineWidth: 2.5 - CGFloat(wave) * 0.5
                    )
                }
            }
        }
        // Smooth transition when toggling animation on/off.
        .animation(.easeInOut(duration: 0.3), value: isAnimating)
    }
}

#Preview {
    ZStack {
        Color.papayaOrange
        WaveformView(isAnimating: true)
            .frame(width: 60, height: 40)
    }
    .frame(width: 100, height: 100)
    .clipShape(Circle())
}
