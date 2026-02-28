//
//  TranslatorContainerView.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 07.10.25.
//

import SwiftUI
import SwiftData

struct TranslatorContainerView: View {
    @State private var state = TranslatorState()
    @State private var playbackState = HandSignPlaybackState()
    @State private var isShowingPractice = false

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SignWord.text) private var signWords: [SignWord]

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
                                    playbackState.replay()
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
                        onAdd: state.presentAddSign,
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
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Practice mode: learn ASL fingerspelling with hand pose detection.
                Button(action: { isShowingPractice = true }) {
                    Image(systemName: "hand.raised.fingers.spread")
                }

                NavigationLink(destination: SignLibraryContainerView()) {
                    Image(systemName: "books.vertical.fill")
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingPractice) {
            PracticeContainerView()
        }
        .animation(.spring(), value: state.recognizedText.isEmpty)
        .animation(.spring(), value: state.unknownWords.isEmpty)
        .animation(.spring(), value: state.isShowingPlayback)
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
        .onChange(of: state.transcriptWords) { _, newWords in
            // Configure the 3D hand playback with all transcript words.
            // Every word can be rendered (dedicated sign or fingerspelling).
            playbackState.setup(with: newWords)
        }
        .sheet(item: $state.addSignWord) { item in
            AddSignView(
                word: item.value,
                onSaveToLibrary: { state.saveSignWord(for: item.value, context: modelContext) },
                onCapture: state.presentCaptureView,
                onCancel: state.dismissAddSign
            )
            .presentationDetents([.medium, .large])
        }
        .fullScreenCover(isPresented: $state.isShowingCaptureView) {
            VideoCaptureContainerView(
                word: state.currentUnknownWord,
                referenceVideoURL: nil,
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
