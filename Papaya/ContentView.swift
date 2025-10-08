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

            Spacer()

            if !speechRecognizer.recognizedText.isEmpty {
                ZStack(alignment: .topTrailing) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(speechRecognizer.recognizedText)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Button(action: {
                        speechRecognizer.reset()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }
                    .padding(8)
                }
                .padding(.horizontal)
            }

            if speechRecognizer.recognizedText.isEmpty {
                Text("Tap the microphone to start recording...")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
            }

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
        .animation(.spring(), value: speechRecognizer.recognizedText.isEmpty)
    }
}

#Preview {
    NavigationStack { ContentView() }
}
