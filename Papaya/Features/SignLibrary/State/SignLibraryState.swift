//
//  SignLibraryViewModel.swift
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
    
    // MARK: - UI State
    var searchText = ""
    var layout: LayoutStyle = .grid
    var displayItems: [LibraryItem] = []
    var selectedItemForPreview: LibraryItem?
    
    private var modelContext: ModelContext?

    // Loading states
    var isLoadingInitialContent = false
    var isSearchingRemotely = false

    private var searchTask: Task<Void, Never>?
    private var initialLoadTask: Task<Void, Never>?

    enum LayoutStyle: String, CaseIterable { case list, grid }
    
    func setup(context: ModelContext) {
        self.modelContext = context
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDatabaseChange),
            name: .NSManagedObjectContextObjectsDidChange,
            object: context
        )
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
            let localItems = localWords.map { LibraryItem(word: $0.text, source: .local(signWord: $0)) }
            
            let remoteItems = await fetchRandomRemoteItems(excluding: localWords, count: 10)
            guard !Task.isCancelled else {
                await MainActor.run { isLoadingInitialContent = false }
                return
            }
            
            await MainActor.run {
                self.displayItems = (localItems + remoteItems).shuffled()
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
            guard !Task.isCancelled else { return }
            
            let cleanedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if !scoredLocalResults.contains(where: { $0.word.lowercased() == cleanedSearchText }) {
                await fetchRemoteResult(for: cleanedSearchText)
            }
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
    
    private func fetchRandomRemoteItems(excluding localWords: [SignWord], count: Int) async -> [LibraryItem] {
        let localWordSet = Set(localWords.map { $0.text.lowercased() })
        let candidates = WordProvider.allWords.filter { !localWordSet.contains($0) }.shuffled().prefix(count)
        
        var remoteItems: [LibraryItem] = []
        await withTaskGroup(of: LibraryItem?.self) { group in
            for word in candidates {
                group.addTask {
                    if let url = await self.videoService.fetchVideoURL(for: word) {
                        return LibraryItem(word: word, source: .remote(url: url))
                    }
                    return nil
                }
            }
            for await item in group {
                if let item = item { remoteItems.append(item) }
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
