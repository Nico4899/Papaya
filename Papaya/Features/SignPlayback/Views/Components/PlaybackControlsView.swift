//
//  PlaybackControlsView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 10.10.25.
//

import SwiftUI

struct PlaybackControlsView: View {
    let isPlaying: Bool
    let playbackRate: Float
    let canGoPrevious: Bool
    let canGoNext: Bool
    
    let onPlayPause: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onReplay: () -> Void
    let onSpeedChange: (Float) -> Void
    
    private let playbackRates: [Float] = [0.5, 1.0, 1.5]

    var body: some View {
        VStack(spacing: 16) {
            Picker("Playback Speed", selection: .init(
                get: { playbackRate },
                set: { onSpeedChange($0) }
            )) {
                ForEach(playbackRates, id: \.self) { rate in
                    Text("\(rate, specifier: "%.1fx")").tag(rate)
                }
            }
            .pickerStyle(.segmented)
            
            HStack(spacing: 32) {
                Button(action: onReplay) {
                    Image(systemName: "backward.end.fill")
                        .font(.title2)
                }
                
                Button(action: onPrevious) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                }
                .disabled(!canGoPrevious)
                
                Button(action: onPlayPause) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 44))
                }
                
                Button(action: onNext) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
                .disabled(!canGoNext)
            }
            .foregroundStyle(.primary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
