//
//  TranslatorContainerView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 07.10.25.
//

import SwiftUI
import SwiftData

struct TranslatorView: View {
    @State private var viewModel: TranslatorViewModel
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SignWord.text) private var signWords: [SignWord]
    
    init() {
        do {
            let container = try ModelContainer(for: SignWord.self)
            let viewModel = TranslatorViewModel(modelContext: container.mainContext)
            
            _viewModel = State(initialValue: viewModel)
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Translator")
                .font(.title2).bold()

            Spacer()
            
            if !viewModel.speechRecognizer.recognizedText.isEmpty {
                TranscriptView(
                    recognizedText: viewModel.speechRecognizer.recognizedText,
                    signWordSet: Set(signWords.map { $0.text.lowercased() }), // Pass the set directly
                    unknownWords: viewModel.unknownWords,
                    selectedUnknownWordIndex: viewModel.selectedUnknownWordIndex,
                    onClear: viewModel.clearTranscription
                )
            } else if !viewModel.speechRecognizer.isRecording {
                Text("Press and hold the button to start recording.")
                    .font(.body).foregroundColor(.secondary).padding()
            }
            
            if !viewModel.unknownWords.isEmpty {
                AddWordView(
                    currentWord: viewModel.currentUnknownWord,
                    isPreviousDisabled: viewModel.selectedUnknownWordIndex <= 0,
                    isNextDisabled: viewModel.selectedUnknownWordIndex >= viewModel.unknownWords.count - 1,
                    onAdd: viewModel.addSelectedWord,
                    onSkip: viewModel.skipUnknownWords,
                    onPrevious: { viewModel.selectedUnknownWordIndex -= 1 },
                    onNext: { viewModel.selectedUnknownWordIndex += 1 }
                )
                .padding(.horizontal).padding(.bottom, 3)
            }

            MicHoldButton(
                isRecording: viewModel.speechRecognizer.isRecording,
                onPressChanged: viewModel.handleMicPress
            )
        }
        .padding()
        .navigationTitle("Papaya")
        .animation(.spring(), value: viewModel.speechRecognizer.recognizedText.isEmpty)
        .animation(.spring(), value: viewModel.unknownWords.isEmpty)
        .onAppear {
            viewModel = TranslatorViewModel(modelContext: modelContext)
            viewModel.updateSignWords(signWords)
        }
        .onChange(of: signWords) {
            viewModel.updateSignWords(signWords)
        }
    }
}

#Preview {
    NavigationStack {
        TranslatorView()
    }
    .modelContainer(for: SignWord.self, inMemory: true)
}
