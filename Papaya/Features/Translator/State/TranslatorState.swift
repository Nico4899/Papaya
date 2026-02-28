//
//  TranslatorViewModel.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 09.10.25.
//

import SwiftUI
import SwiftData
import OSLog

@Observable
class TranslatorState {
    // MARK: - Dependencies
    private var speechRecognizer = SpeechRecognizer()

    // MARK: - Feature State
    var recognizedText: String = ""
    var unknownWords: [String] = []
    var selectedUnknownWordIndex: Int = 0
    var isShowingPlayback = false

    // The word currently being added via the add-sign sheet.
    var addSignWord: IdentifiableString?

    var videoCaptureState = VideoCaptureState()
    var isShowingCaptureView = false

    private var knownWords: Set<String> = []

    init() {
        speechRecognizer.onTranscriptUpdate = { [weak self] newText in
            self?.recognizedText = newText
            self?.updateUnknownWords()
        }
    }

    // MARK: - Computed Properties
    var isRecording: Bool {
        speechRecognizer.isRecording
    }

    var currentUnknownWord: String {
        guard unknownWords.indices.contains(selectedUnknownWordIndex) else {
            return ""
        }
        return unknownWords[selectedUnknownWordIndex]
    }

    /// All words from the transcript, cleaned and ready for playback.
    /// Since the 3D hand can render any word (fingerspelling fallback),
    /// we pass all words through — not just "known" ones.
    var transcriptWords: [String] {
        recognizedText
            .components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { !$0.isEmpty }
    }

    // MARK: - Public Methods (Intents)
    func toggleRecording(isPressed: Bool) {
        if isPressed {
            isShowingPlayback = false
            Task {
                let hasMic = await PermissionManager.requestMicrophoneAccess()
                let hasSpeech = await PermissionManager.requestSpeechRecognitionAccess()
                await MainActor.run {
                    if hasMic && hasSpeech {
                        speechRecognizer.startRecording()
                    } else {
                        Logger.ui.error("Microphone or speech recognition permission denied.")
                    }
                }
            }
        } else {
            speechRecognizer.stopRecording()
        }
    }

    func checkPlaybackEligibility() {
        // With the 3D hand system, we can play back any transcript — even words
        // not in the library will be fingerspelled. So we show playback as long
        // as there is text, regardless of unknown words.
        if !recognizedText.isEmpty {
            isShowingPlayback = true
            Logger.ui.info("Transcript available. Switching to playback view.")
        }
    }

    func resetTranscript() {
        self.recognizedText = ""
        speechRecognizer.reset()
        self.unknownWords = []
        self.selectedUnknownWordIndex = 0
        self.isShowingPlayback = false
    }

    func selectNextWord() {
        if selectedUnknownWordIndex < unknownWords.count - 1 {
            selectedUnknownWordIndex += 1
        }
    }

    func selectPreviousWord() {
        if selectedUnknownWordIndex > 0 {
            selectedUnknownWordIndex -= 1
        }
    }

    // MARK: - Data Logic

    func updateKnownWords(from signWords: [SignWord]) {
        let newKnownWords = Set(signWords.map { $0.text.lowercased() })
        if newKnownWords != self.knownWords {
            self.knownWords = newKnownWords
            // Re-evaluate unknown words if the library has changed.
            self.updateUnknownWords()
        }
    }

    func updateUnknownWords() {
        let words = recognizedText.components(separatedBy: .whitespacesAndNewlines)
        var foundWords = Set<String>()

        let currentUnknown = words.compactMap { word -> String? in
            let cleanedWord = word.trimmingCharacters(in: .punctuationCharacters)
            if !cleanedWord.isEmpty && !knownWords.contains(cleanedWord.lowercased()) && !foundWords.contains(cleanedWord.lowercased()) {
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

    /// Presents the add-sign sheet for the currently selected unknown word.
    func presentAddSign() {
        self.addSignWord = IdentifiableString(value: currentUnknownWord)
    }

    /// Presents the camera capture view for recording a custom sign video.
    func presentCaptureView() {
        Task {
            let hasPermission = await PermissionManager.requestCameraAccess()
            await MainActor.run {
                if hasPermission {
                    self.addSignWord = nil
                    self.isShowingCaptureView = true
                } else {
                    Logger.ui.error("Camera permission denied.")
                }
            }
        }
    }

    /// Saves a new word to the sign library, optionally with a captured video.
    func saveSignWord(for word: String, capturedVideoURL: URL? = nil, context: ModelContext) {
        var finalVideoFileName: String?

        if let sourceURL = capturedVideoURL {
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                Logger.data.error("Could not find the documents directory.")
                return
            }
            let fileName = sourceURL.lastPathComponent
            let destinationURL = documentsDirectory.appendingPathComponent(fileName)

            do {
                try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
                finalVideoFileName = fileName
            } catch {
                Logger.data.error("Error moving video file: \(error.localizedDescription)")
                return
            }
        }

        let newWord = SignWord(text: word.lowercased(), videoFileName: finalVideoFileName)
        context.insert(newWord)

        unknownWords.removeAll { $0.lowercased() == word.lowercased() }
        if selectedUnknownWordIndex >= unknownWords.count {
            selectedUnknownWordIndex = max(0, unknownWords.count - 1)
        }

        isShowingCaptureView = false
        dismissAddSign()

        checkPlaybackEligibility()
    }

    func dismissAddSign() {
        addSignWord = nil
    }
}
