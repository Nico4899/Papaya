//
//  SignPlaybackView.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 10.10.25.
//

import SwiftUI

struct SignPlaybackContainerView: View {
    var state: HandSignPlaybackState

    var body: some View {
        VStack(spacing: 12) {
            // The current word label above the 3D hand.
            if !state.currentWord.isEmpty {
                Text(state.currentWord.uppercased())
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.papayaOrange)
                    .transition(.opacity)
                    .animation(.easeInOut, value: state.currentWord)
            }

            // 3D hand sign view replaces the old VideoPlayer.
            HandSignView(scene: state.scene)
                .aspectRatio(3 / 4, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.systemGray6))
                )
                .shadow(color: .black.opacity(0.15), radius: 8)

            PlaybackControlsView(
                isPlaying: state.isPlaying,
                playbackRate: state.playbackRate,
                canGoPrevious: state.currentIndex > 0,
                canGoNext: state.currentIndex < state.totalCount - 1,
                currentIndex: state.currentIndex,
                totalCount: state.totalCount,
                onPlayPause: state.playPause,
                onPrevious: state.previousTrack,
                onNext: state.nextTrack,
                onSpeedChange: state.setPlaybackRate
            )
        }
        .padding()
        .onAppear {
            // Auto-play when the view appears.
            if !state.isPlaying && state.totalCount > 0 {
                state.play()
            }
        }
    }
}

#Preview("Populated Player") {
    let previewState = HandSignPlaybackState()
    previewState.setup(with: ["hello", "world"])
    return SignPlaybackContainerView(state: previewState)
        .padding()
        .background(Color(.systemGray6))
}
