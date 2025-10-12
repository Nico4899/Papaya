//
//  Untitled.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 09.10.25.
//

import SwiftUI

struct AddWordView: View {
    let currentWord: String
    let canGoPrevious: Bool
    let canGoNext: Bool
    
    var onAdd: () -> Void
    var onPrevious: () -> Void
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: onPrevious) {
                    Image(systemName: "chevron.left")
                }
                .disabled(!canGoPrevious)
                
                Spacer()
                
                Text(currentWord)
                    .font(.title3.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                }
                .disabled(!canGoNext)
            }
            .padding(.horizontal)
            .frame(height: 40)
            .background(Color(.secondarySystemBackground))
            .clipShape(Capsule())
            
            Button("Learn & Capture", systemImage: "camera.fill", action: onAdd)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .font(.headline)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    AddWordView(
        currentWord: "Example",
        canGoPrevious: true,
        canGoNext: true,
        onAdd: {},
        onPrevious: {},
        onNext: {}
    )
    .padding()
}
