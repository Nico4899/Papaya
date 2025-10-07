//
//  TranslatorContainerView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 07.10.25.
//

import SwiftUI

struct TranslatorContainerView: View {
    @State private var isRecording = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Translator")
                .font(.title2)
                .bold()
            
            MicHoldButton(
                isRecording: isRecording,
                onPressChanged: { pressed in
                    isRecording = pressed
                }
            )
        }
        .padding()
        .navigationTitle("Papaya")
        .animation(.default, value: isRecording)
    }
}

#Preview {
    NavigationStack { TranslatorContainerView() }
}
