//
//  PapayaApp.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 07.10.25.
//

import SwiftUI
import SwiftData

@main
struct PapayaApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                WelcomeView()
            }
        }
        .modelContainer(for: SignWord.self)
    }
}
