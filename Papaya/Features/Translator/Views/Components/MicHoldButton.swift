//
//  MicHoldButton.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 08.10.25.
//

import SwiftUI

struct MicHoldButton: View {
    let isRecording: Bool
    let onPressChanged: (Bool) -> Void
    
    @State private var isPressed = false

    var body: some View {
        Circle()
            .fill(isRecording ? Color.red.gradient : Color.accentColor.gradient)
            .frame(width: 72, height: 72)
            .overlay(
                Image(systemName: isRecording ? "waveform" : "mic.fill")
                    .font(.title)
                    .foregroundStyle(.white)
            )
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
            .scaleEffect(isPressed ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onLongPressGesture(minimumDuration: .infinity,
                                pressing: { pressing in
                self.isPressed = pressing
                onPressChanged(pressing)
            }, perform: {})
    }
}

#Preview {
    MicHoldButton(isRecording: false, onPressChanged: { _ in })
        .padding()
}
