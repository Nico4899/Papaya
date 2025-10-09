//
//  TranslatorContainerView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 07.10.25.
//

import SwiftUI
import SwiftData

struct TranslatorView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SignWord.text) private var signWords: [SignWord]
    
    private var signWordSet: Set<String> {
        Set(signWords.map { $0.text.lowercased() })
    }

    // State for managing unknown words
    @State private var unknownWords: [String] = []
    @State private var selectedUnknownWordIndex: Int = 0

    var body: some View {
        VStack(spacing: 24) {
            Text("Translator")
                .font(.title2).bold()

            Spacer()
            
            // Transcript View
            if !speechRecognizer.recognizedText.isEmpty {
                ZStack(alignment: .topTrailing) {
                    ScrollView {
                        styledTranscriptView()
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Button(action: speechRecognizer.reset) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2).foregroundStyle(.gray)
                    }.padding(8)
                }
                .padding(.horizontal)
            } else {
                if !speechRecognizer.isRecording {
                    Text("Press and hold the button to start recording.")
                        .font(.body).foregroundColor(.secondary).padding()
                }
            }

            if !unknownWords.isEmpty {
                AddWordView(
                    unknownWords: $unknownWords,
                    selectedIndex: $selectedUnknownWordIndex,
                    onAdd: { wordToAdd in
                        add(word: wordToAdd)
                    }
                )
                .padding(.horizontal).padding(.bottom, 3)
            }

            // Mic Button
            MicHoldButton(
                isRecording: speechRecognizer.isRecording,
                onPressChanged: { isPressed in
                    if isPressed {
                        addDefaultWordsIfNecessary()
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
        .animation(.spring(), value: unknownWords.isEmpty)
        .onChange(of: speechRecognizer.recognizedText) {
            updateUnknownWords()
        }
    }
    
    private func add(word: String) {
        let cleanedWord = word.trimmingCharacters(in: .punctuationCharacters).lowercased()
        guard !cleanedWord.isEmpty else { return }
        let newWord = SignWord(text: cleanedWord)
        modelContext.insert(newWord)
        updateUnknownWords() // Refresh the list after adding a word
    }
    
    private func updateUnknownWords() {
        let words = speechRecognizer.recognizedText.components(separatedBy: .whitespacesAndNewlines)
        var foundWords = Set<String>()
        
        let currentUnknown = words.compactMap { word -> String? in
            let cleanedWord = word.trimmingCharacters(in: .punctuationCharacters)
            if !cleanedWord.isEmpty && !signWordSet.contains(cleanedWord.lowercased()) && !foundWords.contains(cleanedWord.lowercased()) {
                foundWords.insert(cleanedWord.lowercased())
                return cleanedWord
            }
            return nil
        }
        
        // Only update if the list of unknown words has actually changed
        if unknownWords != currentUnknown {
            unknownWords = currentUnknown
            selectedUnknownWordIndex = 0
        }
    }
    
    private func styledTranscriptView() -> Text {
            let words = speechRecognizer.recognizedText.components(separatedBy: .whitespacesAndNewlines)
            let selectedWord = unknownWords.indices.contains(selectedUnknownWordIndex) ? unknownWords[selectedUnknownWordIndex] : nil

        var finalAttributedString = AttributedString()

        for word in words {
            let cleanedWord = word.trimmingCharacters(in: .punctuationCharacters)
            var attributedWord = AttributedString(word + " ")

            if !cleanedWord.isEmpty && !signWordSet.contains(cleanedWord.lowercased()) {
                let isSelected = cleanedWord.caseInsensitiveCompare(selectedWord ?? "") == .orderedSame
                let backgroundColor = Color.red.opacity(isSelected ? 0.4 : 0.2)
                
                if let range = attributedWord.range(of: word) {
                    attributedWord[range].backgroundColor = backgroundColor
                }
            }
            finalAttributedString.append(attributedWord)
        }
        return Text(finalAttributedString)
    }
    
    private func addDefaultWordsIfNecessary() {
        if signWords.isEmpty {
            let defaultWords = [
                "hello", "world", "goodbye", "weather", "sport"
            ]
            for word in defaultWords {
                add(word: word)
            }
        }
    }
}

#Preview {
    NavigationStack { TranslatorView() }
        .modelContainer(for: SignWord.self, inMemory: true)
}
