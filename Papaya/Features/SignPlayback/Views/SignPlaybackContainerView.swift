//
//  SignPlaybackView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 10.10.25.
//

import SwiftUI
import AVKit

struct SignPlaybackContainerView: View {
    @Bindable var state: SignPlaybackState
    
    var body: some View {
        VStack(spacing: 12) {
            VideoPlayer(player: state.player)
                .aspectRatio(9 / 16, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 8)
            
            PlaybackControlsView(
                isPlaying: state.isPlaying,
                playbackRate: state.playbackRate,
                canGoPrevious: state.currentIndex > 0 || (state.player.currentTime().seconds > 0),
                canGoNext: state.currentIndex < state.player.items().count - 1,
                currentIndex: state.currentIndex,
                totalCount: state.player.items().count,
                onPlayPause: state.playPause,
                onPrevious: state.previousTrack,
                onNext: state.nextTrack,
                onSpeedChange: state.setPlaybackRate
            )
        }
        .padding()
    }
}

#Preview("Populated Player") {
    let previewState = SignPlaybackState()
    let mockSignWords = [
        SignWord(text: "hello", videoFileName: "hello.mp4"),
        SignWord(text: "papaya", videoFileName: "papaya.mp4"),
        SignWord(text: "world", videoFileName: "world.mp4")
    ]
    previewState.setup(with: mockSignWords)
    return SignPlaybackContainerView(state: previewState)
        .padding()
        .background(Color(.systemGray6))
        .modelContainer(for: SignWord.self, inMemory: true)
}
