//
//  SignPreviewView.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 12.10.25.
//

import SwiftUI

/// A full preview sheet for a sign, showing the animated 3D hand model
/// with playback controls. Replaces the former video-based VideoPreviewView.
struct SignPreviewView: View {
    let item: LibraryItem

    @State private var playbackState = HandSignPlaybackState()
    @State private var hasStartedPlayback = false

    var body: some View {
        VStack(spacing: 20) {
            // Drag indicator for the sheet.
            Capsule()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Text(item.word.capitalized)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))

            // Sign type indicator.
            HStack(spacing: 6) {
                if item.hasDedicatedSign {
                    Image(systemName: "hand.raised.fill")
                    Text("ASL Sign")
                } else {
                    Image(systemName: "textformat.abc")
                    Text("Fingerspelled")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            // 3D hand view.
            HandSignView(scene: playbackState.scene)
                .aspectRatio(3 / 4, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.systemGray6))
                )
                .shadow(color: .black.opacity(0.1), radius: 8)

            // Simple play/pause control.
            HStack(spacing: 24) {
                Button(action: {
                    playbackState.replay()
                    playbackState.play()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                }

                Button(action: playbackState.playPause) {
                    Image(systemName: playbackState.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 24))
                        .frame(width: 48, height: 48)
                        .background(Color.papayaOrange, in: Circle())
                        .foregroundStyle(.white)
                        .shadow(color: .papayaOrange.opacity(0.4), radius: 8, y: 4)
                }

                // Speed control.
                Menu {
                    Picker("Speed", selection: .init(
                        get: { playbackState.playbackRate },
                        set: { playbackState.setPlaybackRate(rate: $0) }
                    )) {
                        Text("0.5x").tag(Float(0.5))
                        Text("1.0x").tag(Float(1.0))
                        Text("1.5x").tag(Float(1.5))
                    }
                } label: {
                    Text("\(playbackState.playbackRate, specifier: "%.1fx")")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.papayaOrange)
                        .frame(width: 50, height: 30)
                        .background(.regularMaterial, in: Capsule())
                }
            }
            .foregroundStyle(.primary)

            Spacer()
        }
        .padding()
        .onAppear {
            guard !hasStartedPlayback else { return }
            hasStartedPlayback = true
            playbackState.setup(with: [item.word])
            playbackState.play()
        }
    }
}

#Preview {
    SignPreviewView(
        item: LibraryItem(word: "hello", signWord: SignWord(text: "hello"))
    )
}
