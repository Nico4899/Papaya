//
//  PracticeContainerView.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 28.02.26.
//

import SwiftUI
import OSLog

/// The main practice mode view where users practice signing ASL letters.
///
/// Layout: The camera feed fills the background, with a 3D reference hand
/// shown in a corner overlay. A match score indicator and letter prompt
/// guide the user through the alphabet.
struct PracticeContainerView: View {
    @State private var state = PracticeState()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // MARK: - Camera Feed Background
            CameraView(session: state.detector.captureSession)
                .ignoresSafeArea()

            // Subtle vignette to help overlays stand out.
            VignetteView()

            // MARK: - Main Content Overlay
            VStack {
                topBar
                Spacer()
                letterPrompt
                matchIndicator
                Spacer()
                bottomControls
            }
            .padding()

            // MARK: - 3D Reference Hand (PiP overlay)
            referenceHandOverlay
        }
        .task {
            await state.setup()
        }
        .onAppear {
            state.startSession()
        }
        .onDisappear {
            state.stopSession()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Close button.
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
            }
            .buttonStyle(CameraControlButtonStyle())

            Spacer()

            // Progress indicator.
            VStack(spacing: 4) {
                Text("Practice ASL")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("\(state.completedCount)/\(state.letters.count)")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.black.opacity(0.5), in: Capsule())

            Spacer()

            // Streak badge.
            if state.streak > 1 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                    Text("\(state.streak)")
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.black.opacity(0.5), in: Capsule())
                .transition(.scale.combined(with: .opacity))
            } else {
                Circle().frame(width: 40, height: 40).hidden()
            }
        }
        .animation(.spring(response: 0.3), value: state.streak)
    }

    // MARK: - Letter Prompt

    /// The large letter the user needs to sign.
    private var letterPrompt: some View {
        VStack(spacing: 8) {
            Text("Sign the letter")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))

            Text(String(state.currentLetter))
                .font(.system(size: 120, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.5), radius: 10)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3), value: state.currentLetter)
        }
    }

    // MARK: - Match Indicator

    /// A visual ring that fills up based on the match score and changes color.
    private var matchIndicator: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background ring.
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 6)
                    .frame(width: 60, height: 60)

                // Progress ring.
                Circle()
                    .trim(from: 0, to: CGFloat(state.matchScore))
                    .stroke(
                        matchColor,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.15), value: state.matchScore)

                // Score text or checkmark.
                if state.isMatching {
                    Image(systemName: "checkmark")
                        .font(.title2.bold())
                        .foregroundStyle(.green)
                        .transition(.scale)
                } else {
                    Text("\(Int(state.matchScore * 100))")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                }
            }
            .animation(.spring(response: 0.3), value: state.isMatching)

            // Hand detection status.
            if !state.isHandDetected {
                Text("Show your hand")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.5), in: Capsule())
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state.isHandDetected)
    }

    /// Color transitions from red → orange → green based on match score.
    private var matchColor: Color {
        if state.matchScore > 0.65 { return .green }
        if state.matchScore > 0.4 { return .orange }
        return .red
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        HStack(spacing: 24) {
            // Shuffle button.
            Button(action: state.shuffleLetters) {
                Label("Shuffle", systemImage: "shuffle")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(CameraControlButtonStyle())

            Spacer()

            // Skip button.
            Button(action: state.skipLetter) {
                Label("Skip", systemImage: "forward.fill")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(CameraControlButtonStyle())
        }
    }

    // MARK: - 3D Reference Hand Overlay

    /// A picture-in-picture style 3D hand showing the target pose.
    private var referenceHandOverlay: some View {
        HandSignView(scene: state.referenceScene)
            .frame(width: 120, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemGray6).opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        state.isMatching ? Color.green : Color.white.opacity(0.5),
                        lineWidth: state.isMatching ? 3 : 2
                    )
            )
            .shadow(radius: 10)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .animation(.spring(response: 0.3), value: state.isMatching)
    }
}

// MARK: - Session Complete View

/// Shown when the user completes all letters in the practice session.
struct PracticeCompleteView: View {
    let completedCount: Int
    let totalCount: Int
    let onRestart: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "hands.clap.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.papayaOrange)

            Text("Great Job!")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))

            Text("You practiced \(completedCount) of \(totalCount) letters.")
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                Button(action: onRestart) {
                    Label("Practice Again", systemImage: "arrow.counterclockwise")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.papayaOrange)
                .controlSize(.large)

                Button("Done", action: onDismiss)
                    .tint(.secondary)
            }
            .padding(.top)
        }
        .padding(32)
    }
}

#Preview {
    PracticeContainerView()
}
