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
    
    @State private var isReferencePlayerVisible = true
    
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
                if isReferencePlayerVisible {
                    referenceVideoPlayer(url: url)
                }
            }
            
            overlays
        }
        .animation(.spring(), value: state.capturePhase)
        .animation(.spring(), value: isReferencePlayerVisible)
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
        return ZStack(alignment: .topTrailing) {
            VideoPlayer(player: AVPlayer(url: url))
            
            Button {
                isReferencePlayerVisible = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white, .black.opacity(0.6))
            }
            .padding(8)
        }
        .aspectRatio(16 / 9, contentMode: .fit)
        .frame(width: 150)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white, lineWidth: 2)
        )
        .padding(.bottom, 120)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
    
    @ViewBuilder
    private var overlays: some View {
        VStack {
            HStack {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.black.opacity(0.5))
                        .clipShape(Circle())
                }
                Spacer()
                
                if !isReferencePlayerVisible && referenceVideoURL != nil && state.capturePhase != .review {
                    Button {
                        isReferencePlayerVisible = true
                    } label: {
                        Image(systemName: "video.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    // A helper view is needed to manage the @State for the binding.
    struct PreviewWrapper: View {
        @State private var state = VideoCaptureState()
        
        var body: some View {
            VideoCaptureContainerView(
                word: "hello",
                referenceVideoURL: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
                onSave: { url in print("Save tapped for URL: \(url)") },
                onCancel: { print("Cancel tapped") }
            )
        }
    }
    
    return PreviewWrapper()
}
