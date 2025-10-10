//
//  TranslatorContainerView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 07.10.25.
//

import SwiftUI
import SwiftData

struct TranslatorContainerView: View {
    @State private var state = TranslatorState()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SignWord.text) private var signWords: [SignWord]
    
    private var signWordSet: Set<String> {
        Set(signWords.map { $0.text.lowercased() })
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Translator")
                .font(.title2).bold()

            Spacer()
            
            // Presentational Transcript View
            if !state.recognizedText.isEmpty {
                TranscriptView(
                    text: state.recognizedText,
                    signWordSet: signWordSet,
                    unknownWords: state.unknownWords,
                    selectedIndex: state.selectedUnknownWordIndex,
                    onReset: state.resetTranscript
                )
            } else if !state.isRecording {
                Text("Press and hold the button to start recording.")
                    .font(.body).foregroundColor(.secondary).padding()
            }

            // Presentational AddWord View
            if !state.unknownWords.isEmpty {
                AddWordView(
                    currentWord: state.currentUnknownWord,
                    canGoPrevious: state.selectedUnknownWordIndex > 0,
                    canGoNext: state.selectedUnknownWordIndex < state.unknownWords.count - 1,
                    onAdd: state.addCurrentWord,
                    onSkip: state.skipUnknownWords,
                    onPrevious: state.selectPreviousWord,
                    onNext: state.selectNextWord
                )
                .padding(.horizontal).padding(.bottom, 3)
            }

            // Presentational Mic Button
            MicHoldButton(
                isRecording: state.isRecording,
                onPressChanged: { isPressed in
                    state.addDefaultWordsIfNecessary(currentWords: signWords)
                    state.toggleRecording(isPressed: isPressed)
                }
            )
        }
        .padding()
        .navigationTitle("Papaya")
        .animation(.spring(), value: state.recognizedText.isEmpty)
        .animation(.spring(), value: state.unknownWords.isEmpty)
        .onAppear {
            state.modelContext = modelContext
        }
        .onChange(of: state.recognizedText) {
            state.updateUnknownWords(knownWords: signWordSet)
        }
        .onChange(of: signWords) {
             state.updateUnknownWords(knownWords: signWordSet)
        }
    }
}

#Preview {
    NavigationStack { TranslatorContainerView() }
        .modelContainer(for: SignWord.self, inMemory: true)
}
