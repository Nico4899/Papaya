//
//  MicHoldButton.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 08.10.25.
//

// MicHoldButton.swift

import SwiftUI
import OSLog
// Lottie is a fantastic third-party library for adding high-quality animations.
// You would add it via Swift Package Manager: https://github.com/airbnb/lottie-ios
import Lottie

struct MicHoldButton: View {
    let isRecording: Bool
    let onPressChanged: (Bool) -> Void
    
    @State private var isPressed = false

    var body: some View {
        ZStack {
            // MARK: - Background Pulse
            // A subtle pulsing circle provides constant feedback that the button is interactive.
            Circle()
                .fill(Color.papayaOrange.opacity(isRecording ? 0.3 : 0.15))
                .frame(width: isRecording ? 120 : 80, height: isRecording ? 120 : 80)
            
            // MARK: - Main Button
            Circle()
                .fill(isRecording ? Color.red.gradient : Color.papayaOrange.gradient)
                .frame(width: 80, height: 80)
                .overlay(
                    LottieView(animation: .named("waveform"))
                        .playbackMode(.playing(.fromProgress(0, toProgress: 1, loopMode: .loop)))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .opacity(isRecording ? 1 : 0)
                        .overlay(
                            Image(systemName: "mic.fill")
                                .font(.title)
                                .scaleEffect(isRecording ? 0.8 : 1)
                                .opacity(isRecording ? 0 : 1)
                        )
                        .foregroundStyle(.white)
                )
                .shadow(color: .black.opacity(0.25), radius: 10, y: 5)
                .scaleEffect(isPressed ? 1.1 : 1.0)
        }
        // Use smooth, spring-based animations for a more natural feel.
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isRecording)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        // The `.sensoryFeedback` modifier is the modern way to add haptics.
        .sensoryFeedback(.impact(weight: .light), trigger: isPressed)
        .onLongPressGesture(minimumDuration: .infinity,
            pressing: { pressing in
                self.isPressed = pressing
                onPressChanged(pressing) // Inform the parent view of the state change.
            },
            perform: {
                // This closure is for when the press completes, which is not used here.
            }
        )
        .onAppear {
            Logger.ui.debug("MicHoldButton appeared.")
        }
    }
}

#Preview {
    MicHoldButton(isRecording: false, onPressChanged: { _ in })
        .padding()
}
