//
//  VideoCaptureContainerView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 11.10.25.
//

import SwiftUI
import AVKit

struct VideoCaptureContainerView: View {
    let word: String
    let referenceVideoURL: URL?
    var onSave: (URL) -> Void
    var onCancel: () -> Void
    
    @State private var state = VideoCaptureState()
    
    var body: some View {
        ZStack {
            // Camera preview fills the background
            CameraView(session: state.cameraService.session)
                .ignoresSafeArea()

            // Main UI Overlay
            VStack {
                Spacer()
                controls
            }
            .padding()

            // Countdown Overlay
            if state.capturePhase == .countingDown {
                Text("\(state.countdown)")
                    .font(.system(size: 150, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(radius: 10)
                    .transition(.opacity.combined(with: .scale))
            }

            // Reference Video (PiP)
            if let url = referenceVideoURL, state.capturePhase != .review {
                referenceVideoPlayer(url: url)
            }
        }
        .animation(.spring(), value: state.capturePhase)
        .onDisappear(perform: state.reset)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var controls: some View {
        switch state.capturePhase {
        case .idle:
            Button("Start Recording") {
                state.startCountdown()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .font(.headline)
        case .recording:
            Button("Stop Recording") {
                state.stopRecording()
            }
            .buttonStyle(.bordered)
            .background(.ultraThinMaterial, in: Capsule())
            .font(.headline)
        case .review:
            if let url = state.recordedVideoURL {
                VideoPlayer(player: AVPlayer(url: url))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .aspectRatio(9 / 16, contentMode: .fit)
                    .frame(maxHeight: 400)
                    .overlay(alignment: .bottom) { reviewButtons(videoURL: url) }
            }
        case .countingDown:
            EmptyView()
        }
    }

    private func reviewButtons(videoURL: URL) -> some View {
        HStack {
            Button("Retake", systemImage: "arrow.counterclockwise", action: state.retake)
            Spacer()
            Button("Save", systemImage: "checkmark.circle.fill") { onSave(videoURL) }
        }
        .font(.title)
        .padding()
        .background(.black.opacity(0.3))
    }

    private func referenceVideoPlayer(url: URL) -> some View {
        VideoPlayer(player: AVPlayer(url: url)) {
            // No overlay content needed
        }
        .frame(width: 120, height: 213) // 9:16 aspect ratio
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white, lineWidth: 2)
        )
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
}
