//
//  SignLibraryState.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 09.10.25.
//

import SwiftUI
import SwiftData
import OSLog

@Observable
class SignLibraryState {
    // MARK: - Dependencies
    var videoCaptureState = VideoCaptureState()

    // MARK: - UI State
    var searchText = ""
    var layout: LayoutStyle = .grid
    var displayItems: [LibraryItem] = []

    // MARK: - Presentation State
    var selectedItemForPreview: LibraryItem?
    var itemToRecapture: SignWord?
    var isShowingCaptureView = false
    var isShowingDeleteConfirmation = false

    private var modelContext: ModelContext?
    private var searchTask: Task<Void, Never>?

    enum LayoutStyle: String, CaseIterable { case list, grid }

    func setup(context: ModelContext) {
        self.modelContext = context
        refreshLibrary()
    }

    // MARK: - Data Loading

    /// Refreshes the library display from the local SwiftData store.
    func refreshLibrary() {
        guard let context = modelContext else { return }

        let localWords = fetchLocalWords(from: context)
        displayItems = localWords
            .map { LibraryItem(word: $0.text, signWord: $0) }
            .sorted { $0.word < $1.word }
    }

    /// Called when search text changes — performs local fuzzy search.
    func onSearchChanged() {
        guard let context = modelContext else { return }
        searchTask?.cancel()

        if searchText.isEmpty {
            refreshLibrary()
            return
        }

        searchTask = Task {
            let localWords = fetchLocalWords(from: context)
            let scoredResults = scoreAndSort(localWords: localWords, for: searchText)
            await MainActor.run { self.displayItems = scoredResults }
        }
    }

    // MARK: - Actions

    func delete(item: LibraryItem) {
        guard let context = modelContext else { return }

        // Delete the associated video file if one exists.
        if let fileName = item.signWord.videoFileName, let url = VideoURLManager.getVideoURL(for: fileName) {
            try? FileManager.default.removeItem(at: url)
        }

        context.delete(item.signWord)
        onSearchChanged()
    }

    func deleteAll() {
        guard let context = modelContext else { return }
        let localWords = fetchLocalWords(from: context)

        for word in localWords {
            if let fileName = word.videoFileName, let url = VideoURLManager.getVideoURL(for: fileName) {
                try? FileManager.default.removeItem(at: url)
            }
            context.delete(word)
        }
        refreshLibrary()
    }

    func startEdit(for item: LibraryItem) {
        self.itemToRecapture = item.signWord
        self.isShowingCaptureView = true
    }

    func saveCapturedVideo(for signWord: SignWord, videoURL: URL, context: ModelContext) {
        // If the SignWord is already in the database, this is an update.
        if signWord.isInserted {
            // Delete the old video file if it exists.
            if let oldFileName = signWord.videoFileName, let oldURL = VideoURLManager.getVideoURL(for: oldFileName) {
                try? FileManager.default.removeItem(at: oldURL)
            }
        }

        // Move the new video file from temp to permanent storage.
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            Logger.data.error("Could not find documents directory.")
            return
        }

        let newFileName = videoURL.lastPathComponent
        let destinationURL = documentsDirectory.appendingPathComponent(newFileName)

        do {
            try FileManager.default.moveItem(at: videoURL, to: destinationURL)

            // Update the model's properties.
            signWord.videoFileName = newFileName
            signWord.updatedAt = .now

            // If the model is new, insert it now.
            if !signWord.isInserted {
                context.insert(signWord)
            }

            // Clean up UI state.
            self.isShowingCaptureView = false
            self.itemToRecapture = nil
            refreshLibrary()

        } catch {
            Logger.data.error("Error moving captured video file: \(error.localizedDescription)")
        }
    }

    // MARK: - Private Helpers

    private func fetchLocalWords(from context: ModelContext) -> [SignWord] {
        let descriptor = FetchDescriptor<SignWord>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        do {
            return try context.fetch(descriptor)
        } catch {
            Logger.data.error("Failed to fetch local words: \(error)")
            return []
        }
    }

    private func scoreAndSort(localWords: [SignWord], for query: String) -> [LibraryItem] {
        let lowercasedQuery = query.lowercased()

        return localWords
            .map { word -> (item: LibraryItem, score: Int) in
                let lowercasedWord = word.text.lowercased()
                var score = 0

                if lowercasedWord == lowercasedQuery { score = 1000
                } else if lowercasedWord.hasPrefix(lowercasedQuery) { score = 500
                } else {
                    let distance = lowercasedWord.levenshteinDistance(to: lowercasedQuery)
                    if distance < 3 {
                        score = 100 - distance
                    }
                }

                let item = LibraryItem(word: word.text, signWord: word)
                return (item, score)
            }
            .filter { $0.score > 0 }
            .sorted { $0.score > $1.score }
            .map { $0.item }
    }
}

extension SignWord {
    var isInserted: Bool {
        return modelContext != nil
    }
}
