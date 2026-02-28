//
//  LibraryItemView.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 12.10.25.
//

import SwiftUI

struct LibraryItemView: View {
    let item: LibraryItem
    let layout: SignLibraryState.LayoutStyle

    var onTap: () -> Void
    var onEdit: () -> Void = {}
    var onDelete: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            Group {
                switch layout {
                case .list: listView
                case .grid: gridView
                }
            }
            .contextMenu {
                Button("Edit Sign", systemImage: "pencil", action: onEdit)
                Button("Delete Sign", systemImage: "trash", role: .destructive, action: onDelete)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(), value: layout)
    }

    // MARK: - Grid View
    private var gridView: some View {
        VStack(alignment: .leading, spacing: 8) {
            handSignPreview

            VStack(alignment: .leading) {
                Text(item.word)
                    .font(.headline)
                    .lineLimit(1)

                signTypeLabel
                    .font(.caption)
            }
            .padding([.horizontal, .bottom], 8)
        }
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(savedBadge)
    }

    // MARK: - List View
    private var listView: some View {
        HStack(spacing: 16) {
            handSignPreview
                .frame(width: 100)

            VStack(alignment: .leading) {
                Text(item.word)
                    .font(.headline)
                signTypeLabel
                    .font(.subheadline)
            }
            Spacer()
        }
    }

    // MARK: - Shared Components

    /// A 3D hand pose preview showing the first frame of this word's sign.
    private var handSignPreview: some View {
        HandSignView(word: item.word)
            .aspectRatio(3 / 4, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
            )
    }

    /// Shows whether the word has a dedicated sign or uses fingerspelling.
    private var signTypeLabel: some View {
        HStack(spacing: 4) {
            if item.hasDedicatedSign {
                Image(systemName: "hand.raised.fill")
                Text("ASL Sign")
            } else {
                Image(systemName: "textformat.abc")
                Text("Fingerspelled")
            }
        }
        .foregroundStyle(.secondary)
    }

    /// A bookmark badge indicating the sign is saved in the library.
    private var savedBadge: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
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

#Preview("Interactive Item") {
    LibraryItemView(
        item: LibraryItem(
            word: "Hello",
            signWord: SignWord(text: "hello")
        ),
        layout: .grid,
        onTap: { print("Item tapped") },
        onEdit: { print("Edit tapped") },
        onDelete: { print("Delete tapped") }
    )
    .padding()
}
