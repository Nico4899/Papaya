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
        ZStack {
            LinearGradient(
                colors: [.papayaTeal.opacity(0.3), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Group {
                    if !state.recognizedText.isEmpty {
                        if state.isShowingPlayback {
                            SignPlaybackContainerView(state: playbackState)
                                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                        } else {
                            TranscriptView(
                                text: state.recognizedText,
                                signWordSet: Set(signWords.map { $0.text.lowercased() }),
                                unknownWords: state.unknownWords,
                                selectedIndex: state.selectedUnknownWordIndex,
                                onReset: {
                                    state.resetTranscript()
                                    playbackState.player.removeAllItems()
                                }
                            )
                        }
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
                .frame(maxHeight: .infinity)
                
                if !state.unknownWords.isEmpty && !state.isShowingPlayback {
                    AddWordView(
                        currentWord: state.currentUnknownWord,
                        canGoPrevious: state.selectedUnknownWordIndex > 0,
                        canGoNext: state.selectedUnknownWordIndex < state.unknownWords.count - 1,
                        onAdd: state.presentVideoPicker,
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
                .padding(.bottom)
            }
            .padding(.vertical)
        }
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
        .onChange(of: state.isRecording) { wasRecording, isRecordingNow in
            if wasRecording && !isRecordingNow {
                state.checkPlaybackEligibility()
            }
        }
        .onAppear {
            // On first appearance, provide the state owner with the known words from the database.
            state.updateKnownWords(from: signWords)
        }
        .onChange(of: signWords) { _, newWords in
            // Keep the state owner updated if the database changes.
            state.updateKnownWords(from: newWords)
        }
        .onChange(of: playbackSignWords) { _, newPlaybackWords in
            // This remains necessary to configure the AVPlayer queue.
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
