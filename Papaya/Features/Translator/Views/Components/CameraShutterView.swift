//
//  CameraShutterView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 13.10.25.
//

import SwiftUI

/// A reusable camera shutter button that visually transforms from a record circle
/// to a stop square, providing clear and intuitive feedback to the user.
struct CameraShutterView: View {
    let isRecording: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // The outer ring provides a larger tap target and visual anchor.
                Circle()
                    .strokeBorder(Color.white, lineWidth: 4)
                    .frame(width: 72, height: 72)

                // The inner shape animates between a circle (record) and a rounded square (stop).
                // This is a standard and universally understood camera UI pattern.
                RoundedRectangle(cornerRadius: isRecording ? 8 : 30, style: .continuous)
                    .fill(isRecording ? Color.red : Color.papayaOrange)
                    .frame(width: isRecording ? 32 : 60, height: isRecording ? 32 : 60)
            }
        }
        // A smooth spring animation makes the transition feel physical and responsive.
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isRecording)
        .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            CameraShutterView(isRecording: false, action: {})
            CameraShutterView(isRecording: true, action: {})
        }
    }
}
