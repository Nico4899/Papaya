//
//  TranslatorViewModel.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 09.10.25.
//

import SwiftUI
import SwiftData

@Observable
final class TranslatorViewModel {
    // MARK: - Properties
    var speechRecognizer = SpeechRecognizer()
    var unknownWords: [String] = []
    var selectedUnknownWordIndex: Int = 0
    
    private var signWordSet: Set<String> = []
    private var modelContext: ModelContext

    // MARK: - Computed Properties
    var currentUnknownWord: String {
        guard unknownWords.indices.contains(selectedUnknownWordIndex) else { return "" }
        return unknownWords[selectedUnknownWordIndex]
    }

    // MARK: - Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public Methods
    func updateSignWords(_ words: [SignWord]) {
        self.signWordSet = Set(words.map { $0.text.lowercased() })
        if speechRecognizer.isRecording == false {
             updateUnknownWords()
        }
    }
    
    func handleMicPress(_ isPressed: Bool) {
        if isPressed {
            addDefaultWordsIfNecessary()
            speechRecognizer.startRecording()
        } else {
            speechRecognizer.stopRecording()
            updateUnknownWords()
        }
    }
    
    func clearTranscription() {
        speechRecognizer.reset()
        updateUnknownWords()
    }
    
    func addSelectedWord() {
        let wordToAdd = currentUnknownWord
        add(word: wordToAdd)
        
        unknownWords.removeAll { $0.lowercased() == wordToAdd.lowercased() }
        if selectedUnknownWordIndex >= unknownWords.count {
            selectedUnknownWordIndex = max(0, unknownWords.count - 1)
        }
        updateUnknownWords() // Refresh highlights
    }
    
    func skipUnknownWords() {
        unknownWords.removeAll()
    }

    // MARK: - Private Methods
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
        
        if unknownWords != currentUnknown {
            unknownWords = currentUnknown
            selectedUnknownWordIndex = 0
        }
    }

    private func add(word: String) {
        let cleanedWord = word.trimmingCharacters(in: .punctuationCharacters).lowercased()
        guard !cleanedWord.isEmpty else { return }
        let newWord = SignWord(text: cleanedWord)
        modelContext.insert(newWord)
    }

    private func addDefaultWordsIfNecessary() {
        if signWordSet.isEmpty {
            let defaultWords = ["hello", "world", "goodbye", "weather", "sport"]
            for word in defaultWords {
                add(word: word)
            }
        }
    }
}
