//
//  PapayaApp.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 07.10.25.
//

import SwiftUI

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
