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
    @State private var playbackState = SignPlaybackState()
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SignWord.text) private var signWords: [SignWord]
    
    private var signWordSet: Set<String> {
        Set(signWords.map { $0.text.lowercased() })
    }
    
    private var playbackSignWords: [SignWord] {
        let transcriptWords = state.recognizedText
            .lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .compactMap { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { !$0.isEmpty }

        let signWordMap = Dictionary(signWords.map { ($0.text, $0) }, uniquingKeysWith: { first, _ in first })
        
        var uniqueOrderedWords: [String] = []
        var seenWords = Set<String>()
        for word in transcriptWords where !seenWords.contains(word) {
            uniqueOrderedWords.append(word)
            seenWords.insert(word)
        }
        
        return uniqueOrderedWords.compactMap { signWordMap[$0] }
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
                        onReset: {
                            state.resetTranscript()
                            playbackState.player.removeAllItems()
                        }
                    )
                } else {
                    Spacer()
                    ContentUnavailableView(
                        "Ready to Translate",
                        systemImage: "waveform",
                        description: Text("Press and hold the microphone to start recording.")
                    )
                }
            }
            
            if !playbackSignWords.isEmpty {
                SignPlaybackContainerView(state: playbackState)
                    .frame(height: 320)
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
            }
            
            VStack {
                if !state.unknownWords.isEmpty {
                    AddWordView(
                        currentWord: state.currentUnknownWord,
                        canGoPrevious: state.selectedUnknownWordIndex > 0,
                        canGoNext: state.selectedUnknownWordIndex < state.unknownWords.count - 1,
                        onAdd: state.presentVideoPicker,
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
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SignLibraryContainerView()) {
                    Image(systemName: "books.vertical.fill")
                }
            }
        }
        .animation(.spring(), value: state.recognizedText.isEmpty)
        .animation(.spring(), value: state.unknownWords.isEmpty)
        .animation(.spring(), value: playbackSignWords.isEmpty)
        .onChange(of: state.recognizedText) {
            state.updateUnknownWords(knownWords: signWordSet)
        }
        .onChange(of: signWords) {
             state.updateUnknownWords(knownWords: signWordSet)
        }
        .onChange(of: playbackSignWords) { _, newPlaybackWords in
            playbackState.setup(with: newPlaybackWords)
        }
        .sheet(item: $state.videoPickerWord) { item in
            SignVideoPickerView(
                word: item.value,
                videoURL: state.fetchedVideoURL,
                isLoading: state.isFetchingVideo,
                onConfirm: { state.saveSignWord(for: item.value, context: modelContext) },
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
                    state.saveSignWord(for: state.currentUnknownWord, capturedVideoURL: url, context: modelContext)
                },
                onCancel: {
                    state.isShowingCaptureView = false
                },
                state: state.videoCaptureState
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
