//
//  Untitled.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 09.10.25.
//

// AddWordView.swift

import SwiftUI
import OSLog

struct AddWordView: View {
    let currentWord: String
    let canGoPrevious: Bool
    let canGoNext: Bool
    
    var onAdd: () -> Void
    var onPrevious: () -> Void
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Word Selection Carousel
            HStack(spacing: 12) {
                // Button for navigating to the previous word.
                Button(action: onPrevious) {
                    Image(systemName: "chevron.left.circle.fill")
                }
                .disabled(!canGoPrevious)
                
                // Display the current word to be added. The `textCase(.uppercase)`
                // provides a distinct visual style.
                Text(currentWord)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity)
                
                // Button for navigating to the next word.
                Button(action: onNext) {
                    Image(systemName: "chevron.right.circle.fill")
                }
                .disabled(!canGoNext)
            }
            .font(.title) // Increase the tap target size of the chevron buttons.
            .foregroundStyle(Color.papayaOrange)
            .padding(.horizontal)
            .frame(height: 50)
            .background(.thinMaterial) // A subtle background separates it from the main view.
            .clipShape(Capsule())
            
            // MARK: - Primary Action Button
            // This is the main call-to-action for this view.
            Button(action: onAdd) {
                Label("Add Sign for \"\(currentWord)\"", systemImage: "plus.circle.fill")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            // Using the branded orange color for the primary action.
            .buttonStyle(.borderedProminent)
            .tint(.papayaOrange)
            .controlSize(.large) // Larger buttons are easier to tap.
        }
        .padding()
        // `.regularMaterial` provides a modern, translucent background that adapts to any content behind it.
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear {
            Logger.ui.info("AddWordView appeared for word: \(self.currentWord)")
        }
    }
}

#Preview {
    AddWordView(
        currentWord: "clear",
        canGoPrevious: true,
        canGoNext: false,
        onAdd: {},
        onPrevious: {},
        onNext: {}
    )
    .padding()
}
