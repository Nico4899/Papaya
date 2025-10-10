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

    var body: some View {
        Circle()
            .fill(isRecording ? Color.red.gradient : Color.accentColor.gradient)
            .frame(width: 72, height: 72)
            .overlay(
                Image(systemName: isRecording ? "waveform" : "mic.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            )
            .onLongPressGesture(minimumDuration: .infinity,
                                pressing: onPressChanged) { }
    }
}

#Preview {
    MicHoldButton(isRecording: false, onPressChanged: { _ in })
        .padding()
}
