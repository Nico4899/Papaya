//
//  TranslatorViewModel.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 09.10.25.
//

import SwiftUI
import SwiftData
import OSLog

@Observable
class TranslatorState {
    // MARK: - Dependencies
    private var speechRecognizer = SpeechRecognizer()
    private let videoService = SignVideoAPIService()

    // MARK: - Feature State
    var recognizedText: String = ""
    var unknownWords: [String] = []
    var selectedUnknownWordIndex: Int = 0
    var isShowingPlayback = false
    
    var videoPickerWord: IdentifiableString?
    var fetchedVideoURL: URL?
    var isFetchingVideo = false
    
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

    // MARK: - Public Methods (Intents)
    func toggleRecording(isPressed: Bool) {
        if isPressed {
            isShowingPlayback = false
            speechRecognizer.startRecording()
        } else {
            speechRecognizer.stopRecording()
        }
    }
    
    func checkPlaybackEligibility() {
        // Only show the player if the transcript is not empty AND there are no unknown words.
        if !recognizedText.isEmpty && unknownWords.isEmpty {
            isShowingPlayback = true
            Logger.ui.info("All words recognized. Switching to playback view.")
        } else {
            Logger.ui.info("Unknown words found or text is empty. Staying in transcript view.")
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
    
    func presentVideoPicker() {
        self.videoPickerWord = IdentifiableString(value: currentUnknownWord)
    }

    @MainActor
    func fetchSignVideo() async {
        guard let word = videoPickerWord else {
            return
        }
        
        isFetchingVideo = true
        fetchedVideoURL = nil
        fetchedVideoURL = await videoService.fetchVideoURL(for: word.value)
        
        if fetchedVideoURL == nil {
            print("Failed to fetch video URL for word: \(word.value)")
        }
        
        isFetchingVideo = false
    }
    
    func presentCaptureView() {
        Task {
            let hasPermission = await PermissionManager.requestCameraAccess()
            await MainActor.run {
                if hasPermission {
                    self.videoPickerWord = nil
                    self.isShowingCaptureView = true
                } else {
                    print("Camera permission denied.")
                }
            }
        }
    }
    
    func saveSignWord(for word: String, capturedVideoURL: URL? = nil, context: ModelContext) {
        var finalVideoFileName: String?
        
        if let sourceURL = capturedVideoURL {
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Error: Could not find the documents directory.")
                return
            }
            let fileName = sourceURL.lastPathComponent
            let destinationURL = documentsDirectory.appendingPathComponent(fileName)

            do {
                try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
                finalVideoFileName = fileName
            } catch {
                print("Error moving video file: \(error.localizedDescription)")
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
        dismissVideoPicker()
        
        checkPlaybackEligibility()
    }
    
    func dismissVideoPicker() {
        videoPickerWord = nil
        fetchedVideoURL = nil
        isFetchingVideo = false
    }
}
