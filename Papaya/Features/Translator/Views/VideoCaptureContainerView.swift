//
//  VideoCaptureContainerView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 11.10.25.
//

// VideoCaptureContainerView.swift

import SwiftUI
import AVKit
import OSLog
import ConfettiSwiftUI

struct VideoCaptureContainerView: View {
    // MARK: - Properties
    let word: String
    let referenceVideoURL: URL?
    var onSave: (URL) -> Void
    var onCancel: () -> Void
    
    @Bindable var state: VideoCaptureState
    
    // UI State
    @State private var isReferencePlayerVisible = true
    @State private var confettiCounter = 0
    
    var body: some View {
        ZStack {
            // The camera view serves as the background.
            // In a real app, you would also handle camera permission errors here.
            CameraView(session: state.cameraService.session)
                .ignoresSafeArea()

            // A subtle vignette effect helps focus the user's eye on the center of the screen
            // and makes overlay controls more legible.
            VignetteView()

            // Main UI VStack for top and bottom controls.
            VStack {
                topBar
                Spacer()
                bottomControls
            }
            .padding()

            // The countdown timer appears centered on the screen.
            if state.capturePhase == .countingDown {
                countdownOverlay
            }
            
            // The reference video player can be shown or hidden.
            if let url = referenceVideoURL, state.capturePhase != .review, isReferencePlayerVisible {
                referenceVideoPlayer(url: url)
            }
            
            // The review view appears as a full-screen overlay after recording.
            if state.capturePhase == .review, let url = state.recordedVideoURL {
                reviewView(url: url)
            }
        }
        .confettiCannon(trigger: $confettiCounter, num: 50, radius: 500)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: state.capturePhase)
        .animation(.spring(), value: isReferencePlayerVisible)
        .onAppear {
            Logger.camera.info("VideoCaptureContainerView appeared for word: '\(self.word)'")
        }
        .onDisappear {
            state.reset()
            Logger.camera.info("VideoCaptureContainerView disappeared, state reset.")
        }
    }
    
    // MARK: - Subviews

    /// The top bar provides context (which word is being recorded) and the primary exit control.
    private var topBar: some View {
        HStack {
            // Cancel Button
            Button(action: onCancel) {
                Image(systemName: "xmark")
            }
            .buttonStyle(CameraControlButtonStyle())
            
            Spacer()
            
            // Context Label
            Text("Signing: \(word.uppercased())")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.black.opacity(0.5), in: Capsule())
            
            Spacer()
            
            // Toggle Reference Video Button
            // This button's visibility depends on whether a reference video exists.
            if referenceVideoURL != nil {
                Button {
                    isReferencePlayerVisible.toggle()
                } label: {
                    Image(systemName: isReferencePlayerVisible ? "video.slash.fill" : "video.fill")
                }
                .buttonStyle(CameraControlButtonStyle())
            } else {
                // A spacer to keep the layout balanced if the button isn't present.
                Circle().frame(width: 40, height: 40).hidden()
            }
        }
    }
    
    /// The bottom controls contain the main shutter button and recording status indicators.
    @ViewBuilder
    private var bottomControls: some View {
        if state.capturePhase == .recording {
            // When recording, show a clear visual indicator with a timer.
            HStack {
                Circle().fill(Color.red).frame(width: 10, height: 10)
                Text("REC")
                if let start = state.recordingStart {
                    Text(start, style: .timer)
                }
            }
            .font(.system(size: 14, weight: .medium, design: .monospaced))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.black.opacity(0.5), in: Capsule())
            .padding(.bottom)
        }
        
        // The shutter button's action changes depending on the capture phase.
        CameraShutterView(isRecording: state.isRecording) {
            switch state.capturePhase {
            case .idle:
                isReferencePlayerVisible = false
                state.startCountdown()
                Logger.camera.info("User started recording countdown.")
            case .recording:
                state.stopRecording()
                Logger.camera.info("User stopped recording.")
            default:
                break // No action in other phases.
            }
        }
    }
    
    /// The review view shown after a video has been captured.
    private func reviewView(url: URL) -> some View {
        ZStack {
            // A black background ensures the video is the focus.
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("Review Your Sign")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.top)
                
                VideoPlayer(player: AVPlayer(url: url))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.horizontal)

                HStack(spacing: 16) {
                    // "Retake" is a secondary action.
                    Button("Retake", systemImage: "arrow.counterclockwise", action: state.retake)
                        .buttonStyle(.bordered)
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                    
                    // "Save" is the primary action, using the brand color.
                    Button("Save Sign", systemImage: "checkmark") {
                        confettiCounter += 1 // Trigger the celebration!
                        // A slight delay allows the user to see the confetti before dismissing.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            onSave(url)
                            Logger.data.info("User saved a new sign for word: '\(self.word)'")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.papayaOrange)
                    .frame(maxWidth: .infinity)
                }
                .font(.headline)
                .fontWeight(.semibold)
                .controlSize(.large)
                .padding()
            }
        }
    }

    /// The large countdown text that overlays the camera view.
    private var countdownOverlay: some View {
        Text("\(state.countdown)")
            .font(.system(size: 150, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.5), radius: 10)
            .transition(.opacity.combined(with: .scale))
    }
    
    /// The small, picture-in-picture style reference video player.
    private func referenceVideoPlayer(url: URL) -> some View {
        VideoPlayer(player: AVPlayer(url: url))
            .aspectRatio(16 / 9, contentMode: .fit)
            .frame(width: 120)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.7), lineWidth: 3)
            )
            .shadow(radius: 10)
            .padding()
            // Placing the PiP view in the top-right corner is a common pattern.
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Supporting Views and Styles

/// A reusable button style for camera controls to ensure consistency.
struct CameraControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
            .padding(12)
            .background(.black.opacity(0.5))
            .clipShape(Circle())
            // Provide visual feedback when the button is pressed.
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// A simple view that adds a dark gradient around the edges of the screen.
struct VignetteView: View {
    var body: some View {
        Rectangle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.5)]),
                    center: .center,
                    startRadius: 200,
                    endRadius: 500
                )
            )
            .ignoresSafeArea()
    }
}

#Preview {
    VideoCaptureContainerView(
        word: "Papaya",
        referenceVideoURL: nil,
        onSave: { _ in },
        onCancel: {},
        state: VideoCaptureState()
    )
}
