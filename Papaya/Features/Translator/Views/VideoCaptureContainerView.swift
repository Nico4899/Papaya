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
                    referenceVideoPlayer(url: url)
                }
            }
            
            overlays
            
            if state.capturePhase == .review, let url = state.recordedVideoURL {
                reviewView(url: url)
            }
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
               isReferencePlayerVisible = false
               state.startCountdown()
           }
           .buttonStyle(.borderedProminent)
           .tint(.red)
           .font(.headline)
       case .recording:
           Button("Stop Recording") { state.stopRecording() }
               .buttonStyle(.bordered)
               .background(.ultraThinMaterial, in: Capsule())
               .font(.headline)
       case .review, .countingDown:
           EmptyView()
       }
   }

   @ViewBuilder
   private func reviewView(url: URL) -> some View {
       VStack {
           VideoPlayer(player: AVPlayer(url: url))
               .ignoresSafeArea()

           HStack(spacing: 16) {
               Button("Retake", systemImage: "arrow.counterclockwise") {
                   state.retake()
               }
               .buttonStyle(.bordered)
               .frame(maxWidth: .infinity)
               
               Button("Save", systemImage: "checkmark") {
                   onSave(url)
               }
               .buttonStyle(.borderedProminent)
               .frame(maxWidth: .infinity)
           }
           .font(.headline)
           .controlSize(.large)
           .padding()
           .background(.regularMaterial)
       }
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
    struct PreviewWrapper: View {
        @State private var state = VideoCaptureState()
        
        var body: some View {
            VideoCaptureContainerView(
                word: "hello",
                referenceVideoURL: URL(string: "https://media.signbsl.com/videos/asl/aslsignbank/mp4/FIND-2916.mp4"),
                onSave: { url in print("Save tapped for URL: \(url)") },
                onCancel: { print("Cancel tapped") }
            )
        }
    }
    
    return PreviewWrapper()
}
