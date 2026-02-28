//
//  LibraryItem.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 12.10.25.
//

import Foundation

/// A lightweight wrapper around `SignWord` for display in the sign library.
/// This decouples the UI layer from the SwiftData model layer.
struct LibraryItem: Identifiable, Hashable {
    let id = UUID()
    let word: String
    let signWord: SignWord

    /// Whether this word has a dedicated ASL sign (vs. fingerspelling fallback).
    var hasDedicatedSign: Bool {
        ASLSignLibrary.hasDedicatedSign(for: word)
    }

    /// Whether the user has recorded a custom video for this sign.
    var hasCustomVideo: Bool {
        signWord.videoFileName != nil
    }
}
