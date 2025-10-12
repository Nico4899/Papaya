//
//  SignLibraryView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 09.10.25.
//

import SwiftUI
import SwiftData

struct SignLibraryContainerView: View {
    @State private var state = SignLibraryState()
    @Query(sort: \SignWord.updatedAt, order: .reverse) private var signWords: [SignWord]
    
    private var columns: [GridItem] = [ GridItem(.adaptive(minimum: 150), spacing: 16) ]
    
    var body: some View {
        NavigationStack {
            Group {
                if state.isLoadingInitialContent {
                    ProgressView("Loading Library...")
                } else if state.displayItems.isEmpty {
                    emptyStateView
                } else {
                    content
                }
            }
            .navigationTitle("Sign Library")
            .searchable(text: $state.searchText, prompt: "Search signs...")
            .toolbar { toolbarContent }
            .task(id: signWords) { // ✅ FIX: Use .task for robust loading
                state.onAppear(localWords: signWords)
            }
            .onChange(of: state.searchText) {
                state.onSearchChanged(localWords: signWords)
            }
            .sheet(item: $state.selectedItemForPreview) { item in
                VideoPreviewView(item: item)
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    private var content: some View {
        ScrollView {
            Group {
                if state.layout == .grid {
                    LazyVGrid(columns: columns, spacing: 16) { items }
                } else {
                    LazyVStack(spacing: 12) { items }
                }
            }
            .padding()
            .overlay {
                if state.isSearchingRemotely { ProgressView() }
            }
        }
    }
    
    @ViewBuilder
    private var items: some View {
        ForEach(state.displayItems) { item in
            LibraryItemView(item: item, layout: state.layout)
                .onTapGesture {
                    state.selectedItemForPreview = item
                }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        if state.searchText.isEmpty {
            ContentUnavailableView("Empty Library", systemImage: "book.closed", description: Text("Signs you save will appear here."))
        } else {
            ContentUnavailableView.search
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                state.layout = (state.layout == .grid ? .list : .grid)
            }) {
                Image(systemName: state.layout == .grid ? "list.bullet" : "square.grid.2x2")
            }
        }
    }
}
