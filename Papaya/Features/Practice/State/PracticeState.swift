//
//  PracticeState.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 28.02.26.
//

import Foundation
import OSLog

/// Observable state that manages the sign language practice session.
///
/// The practice mode cycles through ASL alphabet letters, using the
/// `HandPoseDetector` to verify the user's hand pose against the reference.
/// When a match is detected (score above threshold), it advances to the next letter.
@Observable
class PracticeState {
    // MARK: - Dependencies
    let detector = HandPoseDetector()
    let referenceScene = HandSignScene()

    // MARK: - Practice State

    /// The set of letters to practice, in order.
    var letters: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

    /// The index of the current letter being practiced.
    var currentLetterIndex: Int = 0

    /// Number of letters successfully matched in a row.
    var streak: Int = 0

    /// Total letters completed in this session.
    var completedCount: Int = 0

    /// Whether the practice session is actively running.
    var isSessionActive: Bool = false

    /// The match threshold — score must exceed this to count as a match.
    let matchThreshold: Float = 0.65

    /// Time the current letter has been held above threshold (for confirmation).
    private var holdStartTime: Date?
    /// How long the user must hold the pose to confirm a match (seconds).
    private let holdDuration: TimeInterval = 0.8
    private var holdTimer: Timer?

    // MARK: - Computed Properties

    var currentLetter: Character {
        guard letters.indices.contains(currentLetterIndex) else { return "A" }
        return letters[currentLetterIndex]
    }

    var currentReferencePose: HandPose {
        ASLAlphabet.pose(for: currentLetter)
    }

    /// The real-time match score from the detector.
    var matchScore: Float {
        detector.matchScore
    }

    /// Whether the user's hand is currently matching the target.
    var isMatching: Bool {
        matchScore >= matchThreshold
    }

    /// Whether a hand is visible in the camera frame.
    var isHandDetected: Bool {
        detector.isHandDetected
    }

    /// Progress through the entire alphabet (0.0–1.0).
    var overallProgress: Float {
        guard !letters.isEmpty else { return 0 }
        return Float(completedCount) / Float(letters.count)
    }

    // MARK: - Session Lifecycle

    /// Sets up the camera and prepares the practice session.
    func setup() async {
        let hasCamera = await PermissionManager.requestCameraAccess()
        await MainActor.run {
            if hasCamera {
                detector.setupCamera()
                updateReferencePose()
                Logger.ui.info("Practice mode set up successfully.")
            } else {
                Logger.ui.error("Camera permission denied for practice mode.")
            }
        }
    }

    /// Starts the practice session.
    func startSession() {
        currentLetterIndex = 0
        streak = 0
        completedCount = 0
        isSessionActive = true
        updateReferencePose()
        detector.startSession()
        startHoldMonitor()
        Logger.ui.info("Practice session started.")
    }

    /// Stops the practice session and cleans up.
    func stopSession() {
        isSessionActive = false
        detector.stopSession()
        holdTimer?.invalidate()
        holdTimer = nil
        holdStartTime = nil
        Logger.ui.info("Practice session stopped. Completed: \(self.completedCount)/\(self.letters.count)")
    }

    /// Advances to the next letter in the sequence.
    func advanceToNextLetter() {
        completedCount += 1

        if currentLetterIndex < letters.count - 1 {
            currentLetterIndex += 1
            streak += 1
        } else {
            // Completed the full alphabet.
            stopSession()
            return
        }

        updateReferencePose()
        holdStartTime = nil
        Logger.ui.info("Advanced to letter \(String(self.currentLetter)). Streak: \(self.streak)")
    }

    /// Skips the current letter and moves to the next one.
    func skipLetter() {
        streak = 0
        if currentLetterIndex < letters.count - 1 {
            currentLetterIndex += 1
        } else {
            stopSession()
            return
        }
        updateReferencePose()
        holdStartTime = nil
    }

    /// Shuffles the letter order for variety.
    func shuffleLetters() {
        letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").shuffled()
        currentLetterIndex = 0
        completedCount = 0
        streak = 0
        updateReferencePose()
    }

    // MARK: - Private Helpers

    /// Updates the reference pose on both the detector and the 3D scene.
    private func updateReferencePose() {
        let pose = currentReferencePose
        detector.referencePose = pose
        referenceScene.animateTo(pose: pose, duration: 0.3)
    }

    /// Starts a timer that monitors whether the user holds the correct pose
    /// long enough to confirm a match.
    private func startHoldMonitor() {
        holdTimer?.invalidate()
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self, self.isSessionActive else { return }

            if self.isMatching {
                if self.holdStartTime == nil {
                    self.holdStartTime = Date()
                } else if let start = self.holdStartTime,
                          Date().timeIntervalSince(start) >= self.holdDuration {
                    // Pose held long enough — advance!
                    self.advanceToNextLetter()
                }
            } else {
                // Reset the hold timer if the pose breaks.
                self.holdStartTime = nil
            }
        }
    }
}
