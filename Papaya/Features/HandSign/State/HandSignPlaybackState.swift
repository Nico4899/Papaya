//
//  HandSignPlaybackState.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 28.02.26.
//

import Foundation
import OSLog

/// Observable state that manages the playback of sign language animations
/// through the 3D hand model, replacing the video-based `SignPlaybackState`.
///
/// This state class drives a `HandSignScene` to animate through a sequence
/// of words, resolving each word to either a dedicated ASL sign or
/// fingerspelling via `ASLSignLibrary`.
@Observable
class HandSignPlaybackState {
    // MARK: - Public State

    /// The SceneKit scene containing the 3D hand model.
    let scene = HandSignScene()

    /// Whether the sequence is currently playing.
    var isPlaying = false

    /// The index of the currently playing word in the sequence.
    var currentIndex = 0

    /// Total number of words in the current sequence.
    var totalCount: Int { words.count }

    /// The current playback speed multiplier.
    var playbackRate: Float = 1.0

    /// The word currently being animated.
    var currentWord: String {
        guard words.indices.contains(currentIndex) else { return "" }
        return words[currentIndex]
    }

    // MARK: - Private State

    /// The list of words to play through.
    private var words: [String] = []

    /// Whether the current sequence has been set up (to avoid redundant rebuilds).
    private var lastSetupWords: [String] = []

    // MARK: - Setup

    /// Configures the playback state with a list of words to animate.
    /// Each word will be resolved to a sign animation or fingerspelling.
    func setup(with words: [String]) {
        // Avoid redundant setup if the word list hasn't changed.
        guard words != lastSetupWords else { return }

        self.words = words
        self.lastSetupWords = words
        self.currentIndex = 0
        self.isPlaying = false

        // Show the first frame of the first word.
        if let first = words.first {
            let keyframes = ASLSignLibrary.keyframes(for: first)
            if let firstPose = keyframes.first?.pose {
                scene.setPose(firstPose)
            }
        } else {
            scene.setPose(.rest)
        }

        Logger.ui.info("HandSignPlaybackState configured with \(words.count) words.")
    }

    // MARK: - Playback Controls (same interface as the old SignPlaybackState)

    /// Toggles play/pause. If the sequence is finished, replays from the start.
    func playPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    /// Starts or resumes playback from the current index.
    func play() {
        guard !words.isEmpty else { return }

        // If we've reached the end, restart from the beginning.
        if currentIndex >= words.count {
            currentIndex = 0
        }

        isPlaying = true

        scene.playWords(
            words,
            speed: playbackRate,
            startIndex: currentIndex
        ) { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false
                Logger.ui.info("Sign playback sequence complete.")
            }
        }

        scene.onWordChanged = { [weak self] index in
            DispatchQueue.main.async {
                self?.currentIndex = index
            }
        }
    }

    /// Pauses playback at the current position.
    func pause() {
        isPlaying = false
        scene.stopSequence()
    }

    /// Advances to the next word in the sequence.
    func nextTrack() {
        guard currentIndex < words.count - 1 else { return }

        let wasPlaying = isPlaying
        pause()
        currentIndex += 1

        // Show the first frame of the new word.
        showCurrentWordFirstFrame()

        if wasPlaying {
            play()
        }
    }

    /// Goes back to the previous word in the sequence.
    func previousTrack() {
        guard currentIndex > 0 else {
            // At the first word, just restart it.
            showCurrentWordFirstFrame()
            return
        }

        let wasPlaying = isPlaying
        pause()
        currentIndex -= 1

        showCurrentWordFirstFrame()

        if wasPlaying {
            play()
        }
    }

    /// Sets the playback speed. Takes effect on the next word transition.
    func setPlaybackRate(rate: Float) {
        playbackRate = rate
        // If currently playing, restart from current position with new speed.
        if isPlaying {
            pause()
            play()
        }
    }

    /// Replays the entire sequence from the beginning.
    func replay() {
        pause()
        currentIndex = 0
        showCurrentWordFirstFrame()
    }

    // MARK: - Private Helpers

    /// Sets the hand to the first frame of the current word (for seeking/previewing).
    private func showCurrentWordFirstFrame() {
        guard words.indices.contains(currentIndex) else { return }
        let keyframes = ASLSignLibrary.keyframes(for: words[currentIndex])
        if let firstPose = keyframes.first?.pose {
            scene.animateTo(pose: firstPose, duration: 0.2)
        }
    }
}
