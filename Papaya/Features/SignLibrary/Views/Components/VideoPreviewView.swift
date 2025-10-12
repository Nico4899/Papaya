//
//  VideoPreviewView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 12.10.25.
//


import SwiftUI
import AVKit

struct VideoPreviewView: View {
    let item: LibraryItem
    @State private var player: AVPlayer?
    
    var body: some View {
        VStack(spacing: 20) {
            Text(item.word)
                .font(.largeTitle.bold())
            
            if let player = player {
                VideoPlayer(player: player)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .aspectRatio(16 / 9, contentMode: .fit)
            } else {
                ProgressView()
            }
        }
        .padding()
        .onAppear(perform: setupPlayer)
    }
    
    private func setupPlayer() {
        var url: URL?
        switch item.source {
        case .local(let signWord):
            if let fileName = signWord.videoFileName {
                url = VideoURLManager.getVideoURL(for: fileName)
            }
        case .remote(let remoteURL):
            url = remoteURL
        }
        
        if let url = url {
            let newPlayer = AVPlayer(url: url)
            self.player = newPlayer
            newPlayer.play()
        }
    }
}
