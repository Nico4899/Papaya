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

    init(text: String) {
        self.text = text
    }
}
