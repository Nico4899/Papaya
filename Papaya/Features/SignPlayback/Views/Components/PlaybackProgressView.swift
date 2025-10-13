import SwiftUI

/// A visual component that displays a series of capsules to indicate the current step
/// in a sequence, such as a multi-video playback queue.
struct PlaybackProgressView: View {
    let totalCount: Int
    let currentIndex: Int
    
    var body: some View {
        HStack(spacing: 4) {
            // Create a capsule for each video in the playback queue.
            ForEach(0..<totalCount, id: \.self) { index in
                Capsule()
                    // The capsule for the current video is solid and uses the app's
                    // primary brand color for clear emphasis.
                    .fill(index == currentIndex ? Color.papayaOrange : Color.secondary.opacity(0.3))
                    // The capsule for the active item is wider to draw more attention.
                    .frame(width: index == currentIndex ? 20 : 8, height: 4)
            }
        }
        // A smooth spring animation makes the transition between steps feel fluid and natural.
        .animation(.spring(), value: currentIndex)
    }
}

#Preview {
    PlaybackProgressView(totalCount: 5, currentIndex: 2)
        .padding()
        .background(Color.gray.opacity(0.2))
}
