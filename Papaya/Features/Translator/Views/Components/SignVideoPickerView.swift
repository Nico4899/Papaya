//
//  AddSignView.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 10.10.25.
//

import SwiftUI
import OSLog

/// A sheet that lets the user add a word to their sign library.
/// Shows a 3D hand preview of how the word will be signed (fingerspelled
/// or dedicated ASL sign) and offers options to save or capture a custom video.
struct AddSignView: View {
    // MARK: - Properties
    let word: String

    var onSaveToLibrary: () -> Void
    var onCapture: () -> Void
    var onCancel: () -> Void

    @State private var previewState = HandSignPlaybackState()
    @State private var hasStartedPreview = false

    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Text("Add Sign for \"\(word.uppercased())\"")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.papayaOrange)

            // Sign type indicator.
            HStack(spacing: 6) {
                if ASLSignLibrary.hasDedicatedSign(for: word) {
                    Image(systemName: "hand.raised.fill")
                    Text("Dedicated ASL Sign")
                } else {
                    Image(systemName: "textformat.abc")
                    Text("Will be fingerspelled")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            // MARK: - 3D Hand Preview
            HandSignView(scene: previewState.scene)
                .aspectRatio(3 / 4, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.systemGray6))
                )
                .shadow(color: .black.opacity(0.15), radius: 8)

            // MARK: - Action Buttons
            VStack(spacing: 12) {
                // "Add to Library" saves the word so it's recognized during translation.
                Button(action: onSaveToLibrary) {
                    Label("Add to Library", systemImage: "plus.circle.fill")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.papayaOrange)

                // "Capture My Sign" lets the user record their own video.
                Button(action: onCapture) {
                    Label("Capture My Sign", systemImage: "camera.fill")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(.papayaOrange)

                Button("Cancel", role: .cancel, action: onCancel)
                    .tint(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .onAppear {
            guard !hasStartedPreview else { return }
            hasStartedPreview = true
            previewState.setup(with: [word])
            previewState.play()
            Logger.ui.info("AddSignView appeared for word: \(self.word)")
        }
    }
}

#Preview {
    AddSignView(
        word: "hello",
        onSaveToLibrary: {},
        onCapture: {},
        onCancel: {}
    )
}
