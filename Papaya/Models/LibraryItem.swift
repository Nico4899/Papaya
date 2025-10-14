//
//  LibraryItem.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 12.10.25.
//

import Foundation

struct LibraryItem: Identifiable, Hashable {
    let id = UUID()
    let word: String
    let source: ItemSource
    
    enum ItemSource: Hashable {
        case local(signWord: SignWord)
        case remote(url: URL)
    }
    
    var isRemote: Bool {
        if case .remote = source {
            return true
        }
        return false
    }
}
