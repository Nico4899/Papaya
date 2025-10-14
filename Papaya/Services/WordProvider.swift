//
//  WordProvider.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 12.10.25.
//

import Foundation

class WordProvider {
    static let allWords: [String] = {
        guard let url = Bundle.main.url(forResource: "wordlist", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("Error: wordlist.txt not found or could not be loaded.")
            return []
        }
        return content.components(separatedBy: .newlines).filter { !$0.isEmpty }
    }()
}
