//
//  WelcomeView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 06.10.25.
//

import SwiftUI
import OSLog
// Lottie is a fantastic third-party library for adding high-quality animations.
// This is where you would import it after adding it via Swift Package Manager.
// import Lottie

struct WelcomeView: View {
    var body: some View {
        // A ZStack allows us to layer a background behind all other content,
        // creating a more immersive, full-screen experience than a simple VStack.
        ZStack {
            // MARK: - Background Gradient
            // The gradient uses the app's brand colors for a strong visual identity.
            // It adapts beautifully to both light and dark mode because our
            // custom colors are defined in the asset catalog.
            LinearGradient(
                gradient: Gradient(colors: [.papayaTeal.opacity(0.6), .papayaOrange.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea() // Ensures the gradient extends to the screen edges.

            // MARK: - Main Content
            VStack(spacing: 20) {
                Spacer() // Pushes content towards the center.

                Image("app-icon-no-text")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    // A subtle shadow adds depth and makes the icon pop from the background.
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                
                // MARK: - Welcome Text
                Text("Welcome to Papaya")
                    // Using a rounded system font feels more modern and approachable.
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary) // Automatically adapts to light/dark mode.

                Text("Translate spoken words into sign language, effortlessly.")
                    .font(.headline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    // .secondary provides a softer color for supplementary text.
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                Spacer()
                Spacer() // Extra spacer to push the button further down for better ergonomics.

                // MARK: - Call to Action Button
                NavigationLink {
                    TranslatorContainerView()
                } label: {
                    // Using a Label provides better semantics than a simple Text view.
                    Label("Start Translating", systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                // A custom button style for our primary call-to-action.
                .buttonStyle(PrimaryActionButtonStyle())
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
        }
        // Hiding the navigation bar creates a cleaner, more focused welcome screen.
        // The user's journey starts with the main call-to-action button.
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            // Using Apple's Logger to track when views appear is great for debugging user flows.
            Logger.ui.info("WelcomeView appeared.")
        }
    }
}

/// A reusable, branded button style for primary actions in the app.
struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.papayaOrange)
            .foregroundStyle(.white) // High contrast text is accessible.
            .clipShape(Capsule()) // A capsule shape is modern and friendly.
            .shadow(color: .papayaOrange.opacity(0.5), radius: 10, y: 5)
            // Provide visual feedback when the button is pressed.
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}


#Preview {
    NavigationStack {
        WelcomeView()
    }
}
