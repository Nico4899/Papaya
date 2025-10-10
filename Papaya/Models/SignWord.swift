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
    
    // TODO: store image path/asset id, createdAt, updatedAt, etc.

    init(text: String) {
        self.text = text
    }
}
