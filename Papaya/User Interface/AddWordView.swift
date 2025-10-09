//
//  Untitled.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 09.10.25.
//

import SwiftUI

struct AddWordView: View {
    @Binding var unknownWords: [String]
    @Binding var selectedIndex: Int
    var onAdd: (String) -> Void
    
    private var currentWord: String {
        guard unknownWords.indices.contains(selectedIndex) else { return "" }
        return unknownWords[selectedIndex]
    }

    var body: some View {
        HStack(spacing: 16) {
            Button("Add") {
                addCurrentWord()
            }.buttonStyle(.borderedProminent)
            
            Text(currentWord)
                .font(.headline)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
            
            Button(action: { selectedIndex -= 1 }) {
                Image(systemName: "arrow.left")
            }.disabled(selectedIndex <= 0)
            
            Button(action: { selectedIndex += 1 }) {
                Image(systemName: "arrow.right")
            }.disabled(selectedIndex >= unknownWords.count - 1)
            
            Spacer()
            
            Button("Skip", action: skip)
                .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private func addCurrentWord() {
        let wordToAdd = currentWord
        onAdd(wordToAdd)
        unknownWords.removeAll { $0.lowercased() == wordToAdd.lowercased() }
        
        if selectedIndex >= unknownWords.count {
            selectedIndex = max(0, unknownWords.count - 1)
        }
    }
    
    private func skip() {
        unknownWords.removeAll()
    }
}
