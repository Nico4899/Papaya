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
        VStack(spacing: 20) {
            Group {
                if !state.recognizedText.isEmpty {
                    TranscriptView(
                        text: state.recognizedText,
                        signWordSet: signWordSet,
                        unknownWords: state.unknownWords,
                        selectedIndex: state.selectedUnknownWordIndex,
                        onReset: state.resetTranscript
                    )
                } else {
                    Spacer()
                    ContentUnavailableView(
                        "Ready to Translate",
                        systemImage: "waveform",
                        description: Text("Press and hold the microphone to start recording.")
                    )
                    Spacer()
                }
            }
            
            VStack {
                if !state.unknownWords.isEmpty {
                    AddWordView(
                        currentWord: state.currentUnknownWord,
                        canGoPrevious: state.selectedUnknownWordIndex > 0,
                        canGoNext: state.selectedUnknownWordIndex < state.unknownWords.count - 1,
                        onAdd: state.presentVideoPicker,
                        onSkip: state.skipUnknownWords,
                        onPrevious: state.selectPreviousWord,
                        onNext: state.selectNextWord
                    )
                }

                MicHoldButton(
                    isRecording: state.isRecording,
                    onPressChanged: { isPressed in
                        state.toggleRecording(isPressed: isPressed)
                    }
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .navigationTitle("Translator")
        .navigationBarTitleDisplayMode(.inline)
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
        .sheet(item: $state.videoPickerWord) { item in
            SignVideoPickerView(
                word: item.value,
                videoURL: state.fetchedVideoURL,
                isLoading: state.isFetchingVideo,
                onConfirm: state.confirmAddWord,
                onCancel: state.dismissVideoPicker
            )
            .onAppear {
                Task {
                    await state.fetchSignVideo()
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}

struct IdentifiableString: Identifiable {
    let value: String
    var id: String { value }
}

#Preview {
    NavigationStack { TranslatorContainerView() }
        .modelContainer(for: SignWord.self, inMemory: true)
}
