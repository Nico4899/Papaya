//
//  SignVideoPickerView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 10.10.25.
//

import SwiftUI
import AVKit

struct SignVideoPickerView: View {
    // MARK: - Properties
    let word: String
    let videoURL: URL?
    let isLoading: Bool
    
    var onConfirm: () -> Void
    var onCapture: () -> Void
    var onCancel: () -> Void
    
    @State private var player: AVPlayer?
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 24) {
            Text("Add Sign for \"\(word)\"")
                .font(.title2)
                .bold()
                .padding(.top)

            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            
                if isLoading {
                    ProgressView()
                } else if let player = player {
                    VideoPlayer(player: player)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    ContentUnavailableView("Video Not Found", systemImage: "video.slash")
                }
            }
            .aspectRatio(16 / 9, contentMode: .fit)

            HStack(spacing: 16) {
                Button("Cancel", role: .cancel, action: onCancel)
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                
                // New capture button
                Button("Capture My Sign", systemImage: "camera.fill", action: onCapture)
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                
                // Changed text for clarity
                Button("Save From Web", systemImage: "checkmark", action: onConfirm)
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .disabled(isLoading || videoURL == nil)
            }
            .font(.headline)
        }
        .padding(.horizontal)
        .onChange(of: videoURL) { _, newURL in
            if let url = newURL {
                let newPlayer = AVPlayer(url: url)
                self.player = newPlayer
                newPlayer.play()
            } else {
                self.player = nil
            }
        }
    }
}

#Preview("States") {
    let sampleURL = URL(string: "https://media.signbsl.com/videos/asl/aslsignbank/mp4/FIND-2916.mp4")

    return VStack(spacing: 40) {
        // 1. Loading State
        SignVideoPickerView(
            word: "Loading",
            videoURL: nil,
            isLoading: true,
            onConfirm: {},
            onCapture: {},
            onCancel: {}
        )
        
        // 2. Video Found State
        SignVideoPickerView(
            word: "Found",
            videoURL: sampleURL,
            isLoading: false,
            onConfirm: {},
            onCapture: {},
            onCancel: {}
        )
        
        // 3. Not Found State
        SignVideoPickerView(
            word: "Not Found",
            videoURL: nil,
            isLoading: false,
            onConfirm: {},
            onCapture: {},
            onCancel: {}
        )
    }
    .padding()
}
