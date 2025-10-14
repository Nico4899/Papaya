//
//  RemoteSignSaveView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 12.10.25.
//

import SwiftUI
import AVKit

struct RemoteSignSaveView: View {
    let item: LibraryItem
    
    var onSaveFromWeb: () -> Void
    var onCapture: () -> Void
    var onCancel: () -> Void
    
    @State private var player: AVPlayer?
    
    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Text("Add \"\(item.word)\" to Library")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            if let player = player {
                VideoPlayer(player: player)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .aspectRatio(16 / 9, contentMode: .fit)
            } else {
                ProgressView()
            }

            Spacer()
            
            VStack(spacing: 12) {
                Button("Capture My Sign", systemImage: "camera.fill", action: onCapture)
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                
                Button("Save Web Video", systemImage: "icloud.and.arrow.down", action: onSaveFromWeb)
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                
                Button("Cancel", action: onCancel)
                    .buttonStyle(.plain)
                    .padding(.top, 8)
            }
            .font(.headline)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .onAppear(perform: setupPlayer)
    }
    
    private func setupPlayer() {
        guard case .remote(let url) = item.source else {
            return
        }
        let newPlayer = AVPlayer(url: url)
        self.player = newPlayer
        newPlayer.play()
    }
}
