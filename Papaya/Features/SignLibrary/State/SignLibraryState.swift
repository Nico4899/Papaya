//
//  SignLibraryState.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 09.10.25.
//

import SwiftUI
import SwiftData

@Observable
class SignLibraryState {
    // MARK: - Dependencies
    private let videoService = SignVideoAPIService()
    
    var videoCaptureState = VideoCaptureState()
    
    // MARK: - UI State
    var searchText = ""
    var layout: LayoutStyle = .grid
    var displayItems: [LibraryItem] = []
    
    // MARK: - Presentation State
    var selectedItemForPreview: LibraryItem?
    var selectedRemoteItem: LibraryItem?
    var itemToRecapture: SignWord?
    var isShowingCaptureView = false
    var isShowingDeleteConfirmation = false
    
    var referenceVideoURLForCapture: URL?
    
    private var modelContext: ModelContext?

    // Loading states
    var isLoadingInitialContent = false
    var isSearchingRemotely = false

    private var searchTask: Task<Void, Never>?
    private var initialLoadTask: Task<Void, Never>?

    enum LayoutStyle: String, CaseIterable { case list, grid }
    
    func setup(context: ModelContext) {
        self.modelContext = context
        onAppear()
    }

    // Called when the view first appears or data changes
    func onAppear() {
        guard searchText.isEmpty, let context = modelContext else {
            return
        }
        
        initialLoadTask?.cancel()
        initialLoadTask = Task {
            await MainActor.run { isLoadingInitialContent = true }
            
            // The state owner now fetches its own data.
            let localWords = fetchLocalWords(from: context)
            let localItems = localWords
                .map { LibraryItem(word: $0.text, source: .local(signWord: $0)) }
                .sorted { $0.word < $1.word }
            
            let remoteItems = await fetchRemoteItems(excluding: localWords, count: 6)
            guard !Task.isCancelled else {
                await MainActor.run { isLoadingInitialContent = false }
                return
            }
            
            await MainActor.run {
                self.displayItems = localItems + remoteItems.sorted { $0.word < $1.word }
                self.isLoadingInitialContent = false
            }
        }
    }

    // Called when search text changes
    func onSearchChanged() {
        guard let context = modelContext else {
            return
        }
        searchTask?.cancel()
        
        if searchText.isEmpty {
            onAppear()
            return
        }

        searchTask = Task {
            let localWords = fetchLocalWords(from: context)
            let scoredLocalResults = scoreAndSort(localWords: localWords, for: searchText)
            await MainActor.run { self.displayItems = scoredLocalResults }
            
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else {
                return
            }
            
            let cleanedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if !scoredLocalResults.contains(where: { $0.word.lowercased() == cleanedSearchText }) {
                await fetchRemoteResult(for: cleanedSearchText)
            }
        }
    }
    
    func delete(item: LibraryItem) {
        guard let context = modelContext, case .local(let signWord) = item.source else {
            return
        }
        
        if let fileName = signWord.videoFileName, let url = VideoURLManager.getVideoURL(for: fileName) {
            try? FileManager.default.removeItem(at: url)
        }
        
        context.delete(signWord)
        onSearchChanged()
    }
    
    func deleteAll() {
        guard let context = modelContext else {
            return
        }
        let localWords = fetchLocalWords(from: context)
        
        for word in localWords {
            if let fileName = word.videoFileName, let url = VideoURLManager.getVideoURL(for: fileName) {
                try? FileManager.default.removeItem(at: url)
            }
            context.delete(word)
        }
        onAppear()
    }
    
    func startEdit(for item: LibraryItem) {
        guard case .local(let signWord) = item.source else {
            return
        }
        self.itemToRecapture = signWord
        self.referenceVideoURLForCapture = nil // No reference video when editing
        self.isShowingCaptureView = true
    }
    
    func saveRemoteItemFromWeb(item: LibraryItem, context: ModelContext) {
        guard case .remote = item.source else {
            return
        }
        
        let newWord = SignWord(text: item.word.lowercased())
        context.insert(newWord)
        
        self.selectedRemoteItem = nil
        onAppear() // Refresh the library
    }
    
    func startCapture(for item: LibraryItem) {
        guard case .remote(let url) = item.source else {
            return
        }
        
        // Create a temporary, unsaved SignWord to pass context.
        self.itemToRecapture = SignWord(text: item.word)
        self.referenceVideoURLForCapture = url
        
        // Dismiss the sheet and immediately present the capture view.
        self.selectedRemoteItem = nil
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
            print("Error: Could not find documents directory.")
            return
        }
        
        let newFileName = videoURL.lastPathComponent
        let destinationURL = documentsDirectory.appendingPathComponent(newFileName)
        
        do {
            try FileManager.default.moveItem(at: videoURL, to: destinationURL)
            
            // Update the model's properties.
            signWord.videoFileName = newFileName
            signWord.updatedAt = .now
            
            // If the model is new (from a remote suggestion), insert it now.
            if !signWord.isInserted {
                context.insert(signWord)
            }
            
            // Clean up UI state.
            self.isShowingCaptureView = false
            self.itemToRecapture = nil
            onAppear() // Refresh the library
            
        } catch {
            print("Error moving captured video file: \(error.localizedDescription)")
        }
    }
    
    private func fetchLocalWords(from context: ModelContext) -> [SignWord] {
        let descriptor = FetchDescriptor<SignWord>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch local words: \(error)")
            return []
        }
    }
    
    // Listens for external changes (e.g., from the Translator view) and refreshes.
    @objc private func handleDatabaseChange() {
        // Only refresh if not actively searching.
        if searchText.isEmpty {
            onAppear()
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
                
                let item = LibraryItem(word: word.text, source: .local(signWord: word))
                return (item, score)
            }
            .filter { $0.score > 0 }
            .sorted { $0.score > $1.score }
            .map { $0.item }
    }
    
    private func fetchRemoteItems(excluding localWords: [SignWord], count: Int) async -> [LibraryItem] {
        let localWordSet = Set(localWords.map { $0.text.lowercased() })
        var candidates = WordProvider.allWords.filter { !localWordSet.contains($0) }.shuffled()
        
        var remoteItems: [LibraryItem] = []
        let maxAttempts = count * 5

        while remoteItems.count < count && !candidates.isEmpty && remoteItems.count < maxAttempts {
            let batch = candidates.prefix(count)
            candidates.removeFirst(min(batch.count, candidates.count))
            
            await withTaskGroup(of: LibraryItem?.self) { group in
                for word in batch {
                    group.addTask {
                        if let url = await self.videoService.fetchVideoURL(for: word) {
                            return LibraryItem(word: word, source: .remote(url: url))
                        }
                        return nil
                    }
                }
                for await item in group {
                    if let item = item, remoteItems.count < count {
                        remoteItems.append(item)
                    }
                }
            }
        }
        return remoteItems
    }
    
    private func fetchRemoteResult(for word: String) async {
        await MainActor.run { isSearchingRemotely = true }

        if let url = await videoService.fetchVideoURL(for: word) {
            let remoteItem = LibraryItem(word: word, source: .remote(url: url))
            await MainActor.run {
                if !self.displayItems.contains(where: { $0.word.lowercased() == word }) {
                    self.displayItems.append(remoteItem)
                }
            }
        }
        
        await MainActor.run { isSearchingRemotely = false }
    }
}

extension SignWord {
    var isInserted: Bool {
        return modelContext != nil
    }
}
