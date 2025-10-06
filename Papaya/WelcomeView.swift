//
//  WelcomeView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 06.10.25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("👋 Welcome to Papaya!")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Your gateway to accessible communication.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Get Started") {
                // TODO: Navigate to next view
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)
        }
        .padding()
    }
}

#Preview {
    WelcomeView()
}
