//
//  SignLibraryViewModel.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 09.10.25.
//

import SwiftUI

@Observable
class SignLibraryState {
    // MARK: - Dependencies
    private let videoService = SignVideoAPIService()
    
    // MARK: - UI State
    var searchText = ""
    var layout: LayoutStyle = .grid
    var displayItems: [LibraryItem] = []
    var selectedItemForPreview: LibraryItem?

    // Loading states
    var isLoadingInitialContent = false
    var isSearchingRemotely = false

    private var searchTask: Task<Void, Never>?
    private var initialLoadTask: Task<Void, Never>?

    enum LayoutStyle: String, CaseIterable { case list, grid }

    // Called when the view first appears or data changes
    func onAppear(localWords: [SignWord]) {
        guard searchText.isEmpty else {
            return
        }
        
        initialLoadTask?.cancel()
        initialLoadTask = Task {
            await MainActor.run { isLoadingInitialContent = true }
            
            // 1. Prepare local items. This is a non-mutable constant.
            let localItems = localWords.map { LibraryItem(word: $0.text, source: .local(signWord: $0)) }
            
            // 2. Fetch remote items into a separate variable.
            let remoteItems = await fetchRandomRemoteItems(excluding: localWords, count: 10)
            
            guard !Task.isCancelled else {
                await MainActor.run { isLoadingInitialContent = false }
                return
            }
            
            // 3. Safely combine the data and update the UI in a single MainActor block.
            await MainActor.run {
                self.displayItems = (localItems + remoteItems).shuffled()
                self.isLoadingInitialContent = false
            }
        }
    }

    // Called when search text changes
    func onSearchChanged(localWords: [SignWord]) {
        searchTask?.cancel()
        
        if searchText.isEmpty {
            onAppear(localWords: localWords)
            return
        }

        searchTask = Task {
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
