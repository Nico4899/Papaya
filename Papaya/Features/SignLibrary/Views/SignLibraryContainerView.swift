//
//  SignLibraryView.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 09.10.25.
//

import SwiftUI
import SwiftData

struct SignLibraryContainerView: View {
    @State private var state = SignLibraryState()
    @Environment(\.modelContext) private var modelContext

    private var columns: [GridItem] = [ GridItem(.adaptive(minimum: 150), spacing: 16) ]

    var body: some View {
        @Bindable var state = state
        NavigationStack {
            Group {
                if state.displayItems.isEmpty {
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
                SignPreviewView(item: item)
            }
            .fullScreenCover(isPresented: $state.isShowingCaptureView) {
                if let signWord = state.itemToRecapture {
                    VideoCaptureContainerView(
                        word: signWord.text,
                        referenceVideoURL: nil,
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
        }
    }

    @ViewBuilder
    private var items: some View {
        ForEach(state.displayItems) { item in
            LibraryItemView(
                item: item,
                layout: state.layout,
                onTap: { state.selectedItemForPreview = item },
                onEdit: { state.startEdit(for: item) },
                onDelete: { state.delete(item: item) }
            )
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
