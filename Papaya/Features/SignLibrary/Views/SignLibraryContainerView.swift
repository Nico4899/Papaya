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
    @Environment(\.modelContext) private var modelContext
    
    private var columns: [GridItem] = [ GridItem(.adaptive(minimum: 150), spacing: 16) ]
    
    private var localItems: [LibraryItem] {
        state.displayItems.filter { !$0.isRemote }
    }
    
    private var remoteItems: [LibraryItem] {
        state.displayItems.filter { $0.isRemote }
    }
    
    var body: some View {
        @Bindable var state = state
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
            .onAppear {
                state.setup(context: modelContext)
            }
            .onChange(of: state.searchText) {
                state.onSearchChanged()
            }
            .sheet(item: $state.selectedItemForPreview) { item in
                VideoPreviewView(item: item)
            }
            .sheet(item: $state.selectedRemoteItem) { item in
                RemoteSignSaveView(
                    item: item,
                    onSaveFromWeb: {
                        state.saveRemoteItemFromWeb(item: item, context: modelContext)
                    },
                    onCapture: {
                        state.startCapture(for: item)
                    },
                    onCancel: { state.selectedRemoteItem = nil }
                )
            }
            .fullScreenCover(isPresented: $state.isShowingCaptureView) {
                if let signWord = state.itemToRecapture {
                    VideoCaptureContainerView(
                        word: signWord.text,
                        referenceVideoURL: state.referenceVideoURLForCapture,
                        onSave: { newVideoURL in
                            state.saveCapturedVideo(for: signWord, videoURL: newVideoURL, context: modelContext)
                        },
                        onCancel: {
                            state.isShowingCaptureView = false
                            state.itemToRecapture = nil
                        },
                        state: state.videoCaptureState
                    )
                }
            }
            .alert("Clear Library", isPresented: $state.isShowingDeleteConfirmation) {
                Button("Delete All Items", role: .destructive) { state.deleteAll() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to permanently delete all your saved signs?")
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
        ForEach(localItems) { item in
            libraryItemView(for: item)
        }
        
        if !remoteItems.isEmpty {
            Section {
                ForEach(remoteItems) { item in
                    libraryItemView(for: item)
                }
            } header: {
                Text("Suggestions")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
            }
        }
    }

    private func libraryItemView(for item: LibraryItem) -> some View {
        LibraryItemView(
            item: item,
            layout: state.layout,
            onTap: {
                if item.isRemote {
                    state.selectedRemoteItem = item
                } else {
                    state.selectedItemForPreview = item
                }
            },
            onEdit: { state.startEdit(for: item) },
            onDelete: { state.delete(item: item) }
        )
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
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button("Clear All", systemImage: "trash", role: .destructive) {
                state.isShowingDeleteConfirmation = true
            }
            .tint(.red)
            
            Button(action: {
                state.layout = (state.layout == .grid ? .list : .grid)
            }) {
                Image(systemName: state.layout == .grid ? "list.bullet" : "square.grid.2x2")
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignLibraryContainerView()
    }
    .modelContainer(for: SignWord.self, inMemory: true)
}
