//
//  Untitled.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 09.10.25.
//

import SwiftUI

struct AddWordView: View {
    let currentWord: String
    let isPreviousDisabled: Bool
    let isNextDisabled: Bool
    
    let onAdd: () -> Void
    let onSkip: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button("Add", action: onAdd)
                .buttonStyle(.borderedProminent)
            
            Text(currentWord)
                .font(.headline)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
            
            Button(action: onPrevious) {
                Image(systemName: "arrow.left")
            }
            .disabled(isPreviousDisabled)
            
            Button(action: onNext) {
                Image(systemName: "arrow.right")
            }
            .disabled(isNextDisabled)
            
            Spacer()
            
            Button("Skip", action: onSkip)
                .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
