//
//  ConfettiEffect.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 28.02.26.
//
//  A lightweight, native confetti cannon effect that replaces the ConfettiSwiftUI
//  third-party dependency. Inspired by simibac/ConfettiSwiftUI (MIT License).
//

import SwiftUI

// MARK: - Confetti Particle Model

/// Represents a single confetti particle with its physics and appearance properties.
private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let shape: ParticleShape
    // Initial velocity and position offsets.
    let xVelocity: CGFloat
    let yVelocity: CGFloat
    let rotationSpeed: Double
    let rotationAxis: (x: CGFloat, y: CGFloat, z: CGFloat)

    enum ParticleShape: CaseIterable {
        case circle, rectangle, triangle
    }

    static func random() -> ConfettiParticle {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .mint]
        return ConfettiParticle(
            color: colors.randomElement() ?? .papayaOrange,
            size: CGFloat.random(in: 6...12),
            shape: ParticleShape.allCases.randomElement() ?? .rectangle,
            xVelocity: CGFloat.random(in: -300...300),
            yVelocity: CGFloat.random(in: -600 ... -300),
            rotationSpeed: Double.random(in: 2...8),
            rotationAxis: (
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                z: CGFloat.random(in: 0...1)
            )
        )
    }
}

// MARK: - Single Particle View

/// Renders an individual confetti particle shape.
private struct ConfettiParticleView: View {
    let particle: ConfettiParticle

    var body: some View {
        Group {
            switch particle.shape {
            case .circle:
                Circle().fill(particle.color)
            case .rectangle:
                Rectangle().fill(particle.color)
            case .triangle:
                TriangleShape().fill(particle.color)
            }
        }
        .frame(width: particle.size, height: particle.size * 0.6)
    }
}

/// A simple triangle shape for confetti variety.
private struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Confetti Cannon View

/// The main confetti cannon overlay that spawns and animates particles.
private struct ConfettiCannonView: View {
    let trigger: Int
    let particleCount: Int

    @State private var particles: [ConfettiParticle] = []
    @State private var animationProgress: CGFloat = 0
    @State private var isVisible = false

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                ConfettiParticleView(particle: particle)
                    .offset(
                        x: animationProgress * particle.xVelocity,
                        y: animationProgress * particle.yVelocity + animationProgress * animationProgress * 800
                    )
                    .rotation3DEffect(
                        .degrees(animationProgress * particle.rotationSpeed * 360),
                        axis: (
                            x: particle.rotationAxis.x,
                            y: particle.rotationAxis.y,
                            z: particle.rotationAxis.z
                        )
                    )
                    .opacity(isVisible ? max(0, 1 - animationProgress * 0.8) : 0)
            }
        }
        .onChange(of: trigger) { _, _ in
            fire()
        }
        .allowsHitTesting(false)
    }

    private func fire() {
        // Generate new particles.
        particles = (0..<particleCount).map { _ in ConfettiParticle.random() }
        animationProgress = 0
        isVisible = true

        // Animate the particles outward with gravity.
        withAnimation(.easeOut(duration: 2.0)) {
            animationProgress = 1.0
        }

        // Clean up after the animation finishes.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            isVisible = false
            particles = []
        }
    }
}

// MARK: - View Modifier

/// A view modifier that adds a confetti cannon overlay, matching the
/// ConfettiSwiftUI API: `.confettiCannon(trigger:num:radius:)`.
struct ConfettiCannonModifier: ViewModifier {
    @Binding var trigger: Int
    var num: Int
    var radius: CGFloat // Kept for API compatibility, not used in the native version.

    func body(content: Content) -> some View {
        content.overlay {
            ConfettiCannonView(trigger: trigger, particleCount: num)
        }
    }
}

extension View {
    /// Adds a confetti cannon effect to the view.
    /// - Parameters:
    ///   - trigger: Increment this binding to fire confetti.
    ///   - num: Number of confetti particles.
    ///   - radius: Spread radius (kept for API compatibility).
    func confettiCannon(trigger: Binding<Int>, num: Int = 50, radius: CGFloat = 500) -> some View {
        modifier(ConfettiCannonModifier(trigger: trigger, num: num, radius: radius))
    }
}
