//
//  SignVideoPickerView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 10.10.25.
//

import SwiftUI
import AVKit
import OSLog

struct SignVideoPickerView: View {
    // MARK: - Properties
    let word: String
    let videoURL: URL?
    let isLoading: Bool
    
    var onConfirm: () -> Void
    var onCapture: () -> Void
    var onCancel: () -> Void
    
    // Using a private state for the player encapsulates its logic within the view.
    @State private var player: AVPlayer?
    @State private var networkError: String?
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Text("Add Sign for \"\(word.uppercased())\"")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.papayaOrange)

            // MARK: - Video Player View
            ZStack {
                // The background provides a consistent frame for the content.
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.regularMaterial)
                
                if isLoading {
                    ProgressView()
                } else if let player {
                    // Using a custom player view for more control in the future.
                    VideoPlayer(player: player)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                } else {
                    // Provide a more informative error message.
                    ContentUnavailableView(
                        "Video Not Found",
                        systemImage: networkError != nil ? "wifi.exclamationmark" : "video.slash",
                        description: Text(networkError ?? "No reference video could be found online.")
                    )
                }
            }
            .aspectRatio(16 / 9, contentMode: .fit)
            .shadow(color: .black.opacity(0.15), radius: 8)
            
            // MARK: - Action Buttons
            VStack(spacing: 12) {
                // "Capture My Sign" is the primary action for the user.
                Button(action: onCapture) {
                    Label("Capture My Sign", systemImage: "camera.fill")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.papayaOrange)
                
                // "Save Web Video" is a secondary, but still important, action.
                Button(action: onConfirm) {
                    Label("Save Web Video", systemImage: "icloud.and.arrow.down.fill")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(.papayaOrange)
                .disabled(isLoading || videoURL == nil)
                
                Button("Cancel", role: .cancel, action: onCancel)
                    .tint(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .onChange(of: videoURL) { _, newURL in
            updatePlayer(with: newURL)
        }
        .onAppear {
            Logger.ui.info("SignVideoPickerView appeared for word: \(self.word)")
            updatePlayer(with: videoURL)
        }
    }
    
    /// Updates the AVPlayer instance when the video URL changes.
    private func updatePlayer(with url: URL?) {
        // Reset first
        player = nil
        networkError = nil

        guard let url else {
            return
        }

        let asset = AVURLAsset(url: url)

        // Use AVFoundation's typed async property loading (iOS 16+)
        Task {
            do {
                let isPlayable = try await asset.load(.isPlayable)

                await MainActor.run {
                    if isPlayable {
                        let item = AVPlayerItem(asset: asset)
                        let newPlayer = AVPlayer(playerItem: item)
                        self.player = newPlayer
                        newPlayer.play()
                    } else {
                        self.networkError = "This video can't be played."
                        Logger.data.error("Asset at \(url.absoluteString, privacy: .public) is not playable.")
                    }
                }
            } catch {
                await MainActor.run {
                    self.networkError = "Could not load video. Please check your internet connection."
                    Logger.data.error("Failed to load asset: \(error.localizedDescription, privacy: .public)")
                    self.player = nil
                }
            }
        }
    }
}


#Preview {
    SignVideoPickerView(
        word: "Found",
        videoURL: URL(string: "https://media.signbsl.com/videos/asl/aslsignbank/mp4/FIND-2916.mp4"),
        isLoading: false,
        onConfirm: {},
        onCapture: {},
        onCancel: {}
    )
}
