//
//  PlaybackControlsView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 10.10.25.
//

import SwiftUI
import OSLog

struct PlaybackControlsView: View {
    // MARK: - Properties
    let isPlaying: Bool
    let playbackRate: Float
    let canGoPrevious: Bool
    let canGoNext: Bool
    
    // New properties to feed the progress view.
    let currentIndex: Int
    let totalCount: Int
    
    let onPlayPause: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onSpeedChange: (Float) -> Void
    
    // An expanded list of playback rates for more user control.
    private let playbackRates: [Float] = [0.5, 1.0, 1.5]

    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            // The new progress view gives the user immediate context about their place in the sequence.
            PlaybackProgressView(totalCount: totalCount, currentIndex: currentIndex)
            
            HStack(spacing: 24) {
                // MARK: - Speed Control Menu
                // A Menu is a much cleaner and more space-efficient UI than a
                // segmented picker for selecting playback speed. It's a standard iOS pattern.
                Menu {
                    Picker("Playback Speed", selection: .init(get: { playbackRate }, set: { onSpeedChange($0) })) {
                        ForEach(playbackRates, id: \.self) { rate in
                            // Use SF Symbols to provide clear visual cues for each speed.
                            Label("\(rate, specifier: "%.1fx")", systemImage: getSpeedIcon(for: rate))
                                .tag(rate)
                        }
                    }
                } label: {
                    // The label clearly displays the current speed and acts as the button.
                    Text("\(playbackRate, specifier: "%.1fx")")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.papayaOrange)
                        .frame(width: 50, height: 30)
                        .background(.regularMaterial, in: Capsule())
                }
                
                Spacer()
                
                // MARK: - Main Transport Controls
                HStack(spacing: 32) {
                    Button(action: onPrevious) {
                        Image(systemName: "backward.fill")
                    }
                    .disabled(!canGoPrevious)
                    
                    // The Play/Pause button is the largest element, establishing it as the
                    // primary control, which follows Apple's HIG for media players.
                    Button(action: onPlayPause) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 24))
                            .frame(width: 48, height: 48)
                            .background(Color.papayaOrange, in: Circle())
                            .foregroundStyle(.white)
                            .shadow(color: .papayaOrange.opacity(0.4), radius: 8, y: 4)
                    }
                    
                    Button(action: onNext) {
                        Image(systemName: "forward.fill")
                    }
                    .disabled(!canGoNext)
                }
                .font(.title2)
                
                Spacer()
                
                // A hidden placeholder to balance the layout with the speed control on the left,
                // ensuring the main transport controls remain perfectly centered.
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 50, height: 30)
            }
            .foregroundStyle(.primary)
        }
        .padding(.vertical)
        .padding(.horizontal, 24)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onAppear {
            Logger.ui.info("PlaybackControlsView appeared.")
        }
    }
    
    /// Helper function to select an appropriate SF Symbol for each playback speed,
    /// adding a touch of personality and improving glanceability.
    private func getSpeedIcon(for rate: Float) -> String {
        switch rate {
        case ..<1.0: return "tortoise.fill"
        case 1.0: return "figure.walk"
        default: return "hare.fill"
        }
    }
}

#Preview {
    PlaybackControlsView(
        isPlaying: false,
        playbackRate: 1.0,
        canGoPrevious: true,
        canGoNext: true,
        currentIndex: 2,
        totalCount: 5,
        onPlayPause: {},
        onPrevious: {},
        onNext: {},
        onSpeedChange: { _ in }
    )
    .padding()
}
