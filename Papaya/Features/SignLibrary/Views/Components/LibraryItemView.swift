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
    
    var onTap: () -> Void
    var onEdit: () -> Void = {}
    var onDelete: () -> Void = {}
    
    @State private var player: AVPlayer?
    
    var body: some View {
        Button(action: onTap) {
            Group {
                switch layout {
                case .list: listView
                case .grid: gridView
                }
            }
            .contextMenu {
                if !item.isRemote {
                    Button("Edit Sign", systemImage: "pencil", action: onEdit)
                    Button("Delete Sign", systemImage: "trash", role: .destructive, action: onDelete)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(), value: layout)
        .onChange(of: item, initial: true) { _, newItem in
            setupPlayer(for: newItem)
        }
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
            Text(signWord.updatedAt.formatted(.relative(presentation: .named)))
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
    
    private func setupPlayer(for item: LibraryItem) {
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
        } else {
            self.player = nil
        }
    }
}

#Preview("Interactive Item") {
    LibraryItemView(
        item: LibraryItem(
            word: "Hello",
            source: .local(signWord: SignWord(text: "hello"))
        ),
        layout: .grid,
        onTap: { print("Item tapped") },
        onEdit: { print("Edit tapped") },
        onDelete: { print("Delete tapped") }
    )
    .padding()
}
