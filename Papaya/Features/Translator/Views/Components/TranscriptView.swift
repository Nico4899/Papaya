//
//  TranscriptView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 09.10.25.
//

import SwiftUI
import OSLog

struct TranscriptView: View {
    let text: String
    let signWordSet: Set<String>
    let unknownWords: [String]
    let selectedIndex: Int
    let onReset: () -> Void
    
    private var selectedWord: String? {
        // Safe access to the selected word.
        unknownWords.indices.contains(selectedIndex) ? unknownWords[selectedIndex] : nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // A clear header for the section.
            Text("Transcript")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            ScrollView {
                // Apply styling to the transcribed text.
                styledText()
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            // Encapsulating the view in a material background for a modern look.
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(alignment: .topTrailing) {
                // The reset button is now more prominent and uses a clear icon.
                Button(action: onReset) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .padding(8)
            }
        }
        .padding(.horizontal)
        .onAppear {
            Logger.ui.info("TranscriptView appeared.")
        }
    }
    
    /// This function constructs an `AttributedString` to style words differently
    /// based on whether they are known or unknown in the sign library.
    private func styledText() -> Text {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        var finalAttributedString = AttributedString()

        for word in words {
            // Clean the word of punctuation for lookup.
            let cleanedWord = word.trimmingCharacters(in: .punctuationCharacters)
            var attributedWord = AttributedString(word + " ")

            // Check if the word is unknown.
            if !cleanedWord.isEmpty && !signWordSet.contains(cleanedWord.lowercased()) {
                let isSelected = cleanedWord.caseInsensitiveCompare(selectedWord ?? "") == .orderedSame
                
                if let range = attributedWord.range(of: word) {
                    // Use the brand color for highlighting unknown words.
                    attributedWord[range].backgroundColor = .papayaHighlight
                    attributedWord[range].foregroundColor = .papayaOrange
                    
                    if isSelected {
                        // The currently selected word gets a stronger visual treatment.
                        attributedWord[range].underlineStyle = .single
                        attributedWord[range].font = .body.weight(.bold)
                    }
                }
            }
            finalAttributedString.append(attributedWord)
        }
        return Text(finalAttributedString)
    }
}

#Preview {
    TranscriptView(
        text: "Hello brave new world, this is a test of communication.",
        signWordSet: ["hello", "world", "a", "of"],
        unknownWords: ["brave", "new", "this", "is", "test", "communication"],
        selectedIndex: 5,
        onReset: { print("Reset tapped") }
    )
    .padding()
}
