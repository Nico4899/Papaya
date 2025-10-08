//
//  TranslatorContainerView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 07.10.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()

    var body: some View {
        VStack(spacing: 24) {
            Text("Translator")
                .font(.title2)
                .bold()

            Text(speechRecognizer.recognizedText)
                .padding()
                .frame(minHeight: 50)

            Spacer()

            MicHoldButton(
                isRecording: speechRecognizer.isRecording,
                onPressChanged: { isPressed in
                    if isPressed {
                        speechRecognizer.startRecording()
                    } else {
                        speechRecognizer.stopRecording()
                    }
                }
            )
        }
        .padding()
        .navigationTitle("Papaya")
        // The animation is now tied to the recognizer's state.
        .animation(.default, value: speechRecognizer.isRecording)
    }
}

#Preview {
    NavigationStack { ContentView() }
}
