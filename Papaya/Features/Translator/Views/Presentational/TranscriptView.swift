//
//  TranscriptView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 09.10.25.
//

import SwiftUI

struct TranscriptView: View {
    let text: String
    let signWordSet: Set<String>
    let unknownWords: [String]
    let selectedIndex: Int
    let onReset: () -> Void
    
    private var selectedWord: String? {
        unknownWords.indices.contains(selectedIndex) ? unknownWords[selectedIndex] : nil
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                styledText()
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(action: onReset) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.gray)
            }.padding(8)
        }
        .padding(.horizontal)
    }
    
    private func styledText() -> Text {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        var finalAttributedString = AttributedString()

        for word in words {
            let cleanedWord = word.trimmingCharacters(in: .punctuationCharacters)
            var attributedWord = AttributedString(word + " ")

            if !cleanedWord.isEmpty && !signWordSet.contains(cleanedWord.lowercased()) {
                let isSelected = cleanedWord.caseInsensitiveCompare(selectedWord ?? "") == .orderedSame
                let backgroundColor = Color.red.opacity(isSelected ? 0.4 : 0.2)
                
                if let range = attributedWord.range(of: word) {
                    attributedWord[range].backgroundColor = backgroundColor
                }
            }
            finalAttributedString.append(attributedWord)
        }
        return Text(finalAttributedString)
    }
}
