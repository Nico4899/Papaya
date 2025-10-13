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
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.2), radius: 8)
            
            PlaybackControlsView(
                isPlaying: state.isPlaying,
                playbackRate: state.playbackRate,
                canGoPrevious: state.currentIndex > 0 || (state.player.currentTime().seconds > 0),
                canGoNext: state.currentIndex < state.player.items().count - 1,
                onPlayPause: state.playPause,
                onPrevious: state.previousTrack,
                onNext: state.nextTrack,
                onReplay: state.replay,
                onSpeedChange: { newRate in
                    state.setPlaybackRate(rate: newRate)
                }
            )
        }
        .padding()
    }
}
