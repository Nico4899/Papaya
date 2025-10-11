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
    
    @Bindable var state = VideoCaptureState()
    
    // MARK: - State for Interactive Player
    @State private var isReferencePlayerVisible = true
    @State private var referencePlayerOffset = CGSize.zero
    @State private var referencePlayerScale: CGFloat = 1.0
    
    // Temporary state for smooth gestures
    @State private var tempDragOffset = CGSize.zero
    @State private var tempMagnification: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            CameraView(session: state.cameraService.session)
                .ignoresSafeArea()

            VStack {
                Spacer()
                controls
            }
            .padding()

            if state.capturePhase == .countingDown {
                Text("\(state.countdown)")
                    .font(.system(size: 150, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(radius: 10)
                    .transition(.opacity.combined(with: .scale))
            }

            if let url = referenceVideoURL, state.capturePhase != .review {
                if isReferencePlayerVisible {
                    interactiveReferencePlayer(url: url)
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

    private func interactiveReferencePlayer(url: URL) -> some View {
        let combinedGesture = DragGesture()
            .simultaneously(with: MagnificationGesture())
            .onChanged { value in
                if let drag = value.first {
                    self.tempDragOffset = drag.translation
                }
                if let magnification = value.second {
                    self.tempMagnification = magnification
                }
            }
            .onEnded { value in
                if let drag = value.first {
                    self.referencePlayerOffset.width += drag.translation.width
                    self.referencePlayerOffset.height += drag.translation.height
                    self.tempDragOffset = .zero
                }

                if let magnification = value.second {
                    self.referencePlayerScale *= magnification
                    self.referencePlayerScale = max(0.5, min(self.referencePlayerScale, 2.0))
                    self.tempMagnification = 1.0
                }
            }

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
        .scaleEffect(referencePlayerScale * tempMagnification)
        .offset(x: referencePlayerOffset.width + tempDragOffset.width,
                y: referencePlayerOffset.height + tempDragOffset.height)
        .padding(.bottom, 120)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .gesture(combinedGesture)
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
