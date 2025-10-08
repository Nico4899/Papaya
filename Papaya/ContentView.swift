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
                        Text(speechRecognizer.recognizedText)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 250)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

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
                Spacer()
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
