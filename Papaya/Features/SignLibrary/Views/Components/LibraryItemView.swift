//
//  LibraryItemView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 12.10.25.
//

import SwiftUI
import AVKit

struct LibraryItemView: View {
    let item: LibraryItem
    let layout: SignLibraryState.LayoutStyle
    
    @State private var player: AVPlayer?
    
    var body: some View {
        Group {
            switch layout {
            case .list: listView
            case .grid: gridView
            }
        }
        .animation(.spring(), value: layout)
        .onAppear(perform: setupPlayer)
    }
    
    // MARK: - Grid View
    private var gridView: some View {
        VStack(alignment: .leading, spacing: 8) {
            videoPlayerView
            
            VStack(alignment: .leading) {
                Text(item.word)
                    .font(.headline)
                    .lineLimit(1)
                
                sourceInfo
                    .font(.caption)
            }
            .padding([.horizontal, .bottom], 8)
        }
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(borderAndBadge)
    }
    
    // MARK: - List View
    private var listView: some View {
        HStack(spacing: 16) {
            videoPlayerView
                .frame(width: 100)
                .overlay(borderAndBadge)
            
            VStack(alignment: .leading) {
                Text(item.word)
                    .font(.headline)
                sourceInfo
                    .font(.subheadline)
            }
            Spacer()
        }
    }
    
    // MARK: - Shared Components
    @ViewBuilder
    private var videoPlayerView: some View {
        if let player = player {
            VideoPlayer(player: player)
                .aspectRatio(16 / 9, contentMode: .fit)
                .disabled(true)
        } else {
            Rectangle()
                .fill(Color.secondary.opacity(0.2))
                .aspectRatio(16 / 9, contentMode: .fit)
                .overlay { Image(systemName: "video.slash") }
        }
    }
        
    
    @ViewBuilder
    private var sourceInfo: some View {
        switch item.source {
        case .local(let signWord):
            Text(signWord.updatedAt, format: .relative(presentation: .named))
                .foregroundStyle(.secondary)
        case .remote:
            HStack(spacing: 4) {
                Image(systemName: "cloud")
                Text("Tap to save")
            }
            .foregroundColor(.accentColor)
        }
    }
    
    @ViewBuilder
    private var borderAndBadge: some View {
        ZStack(alignment: .topLeading) {
            // Dashed border for remote items
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: (item.isRemote ? [5] : [])))
                .foregroundStyle(Color.accentColor.opacity(item.isRemote ? 0.7 : 0))
            
            // "Saved" badge for local items
            if !item.isRemote {
                Image(systemName: "bookmark.fill")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(5)
                    .background(Color.accentColor.gradient)
                    .clipShape(Circle())
                    .padding(6)
            }
        }
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
            self.player = AVPlayer(url: url)
        }
    }
}
