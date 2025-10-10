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

            NavigationLink {
                TranslatorContainerView()
            } label: {
                Text("Get Started")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { WelcomeView() }
}
