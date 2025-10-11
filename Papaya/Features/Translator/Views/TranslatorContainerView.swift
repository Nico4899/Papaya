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
                
                Spacer()

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
        .toolbar {
            if !state.recognizedText.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Session", systemImage: "plus", action: state.resetTranscript)
                }
            }
        }
        .animation(.spring(), value: state.recognizedText.isEmpty)
        .animation(.spring(), value: state.unknownWords.isEmpty)
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
                onConfirm: { state.confirmAddWord(context: modelContext) },
                onCapture: state.presentCaptureView,
                onCancel: state.dismissVideoPicker
            )
            .onAppear {
                Task {
                    await state.fetchSignVideo()
                }
            }
            .presentationDetents([.medium, .large])
        }
        .fullScreenCover(isPresented: $state.isShowingCaptureView) {
            VideoCaptureContainerView(
                word: state.currentUnknownWord,
                referenceVideoURL: state.fetchedVideoURL,
                onSave: { url in
                    state.saveCapturedVideo(url: url, for: state.currentUnknownWord, context: modelContext)
                },
                onCancel: {
                    state.isShowingCaptureView = false
                }
            )
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
