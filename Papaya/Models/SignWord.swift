//
//  SignWord.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 09.10.25.
//

import Foundation
import SwiftData

@Model
final class SignWord {
    @Attribute(.unique)
    var text: String
    
    var videoFileName: String?
    var createdAt: Date
    var updatedAt: Date

    init(text: String, videoFileName: String? = nil, createdAt: Date = .now, updatedAt: Date = .now) {
        self.text = text
        self.videoFileName = videoFileName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
