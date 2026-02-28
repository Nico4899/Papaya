//
//  ASLSignLibrary.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 28.02.26.
//

import Foundation

/// A library of common ASL signs represented as keyframe animation sequences.
///
/// Each sign is a series of `SignKeyframe`s that animate the 3D hand model
/// through the movements of the sign. Words not found here fall back to
/// fingerspelling via `ASLAlphabet`.
///
/// Reference: Simplified approximations of standard ASL signs.
enum ASLSignLibrary {
    // MARK: - Shorthand Helpers

    private static let open: Float = 0.0
    private static let slight: Float = 0.2
    private static let half: Float = 0.7
    private static let full: Float = 1.45

    private static func curled(spread: Float = 0) -> FingerPose {
        FingerPose(curl: [full, full, full], spread: spread)
    }

    private static func straight(spread: Float = 0) -> FingerPose {
        FingerPose(curl: [open, open, open], spread: spread)
    }

    /// All fingers extended, thumb out — a flat open hand.
    private static let openHand = HandPose(
        thumb: FingerPose(curl: [open, open, open], spread: 0.5),
        index: straight(spread: 0.08),
        middle: straight(spread: 0.0),
        ring: straight(spread: -0.08),
        pinky: straight(spread: -0.15)
    )

    /// A closed fist.
    private static let fist = HandPose(
        thumb: FingerPose(curl: [half, half, open], spread: -0.1),
        index: curled(),
        middle: curled(),
        ring: curled(),
        pinky: curled()
    )

    // MARK: - Sign Dictionary

    /// Maps lowercase words to their keyframe sequences.
    /// The playback system looks up words here before falling back to fingerspelling.
    static let signs: [String: [SignKeyframe]] = [
        // HELLO: Open hand waves near the forehead (simplified to a palm-out wave).
        "hello": [
            SignKeyframe(openHand.with(wrist: WristPose(yaw: -0.2)), duration: 0.3),
            SignKeyframe(openHand.with(wrist: WristPose(yaw: 0.2)), duration: 0.25),
            SignKeyframe(openHand.with(wrist: WristPose(yaw: -0.2)), duration: 0.25),
            SignKeyframe(openHand, duration: 0.2),
        ],

        // YES: Fist nods forward (like a head nodding).
        "yes": [
            SignKeyframe(fist.with(wrist: WristPose(pitch: -0.3)), duration: 0.25),
            SignKeyframe(fist.with(wrist: WristPose(pitch: 0.3)), duration: 0.25),
            SignKeyframe(fist.with(wrist: WristPose(pitch: -0.3)), duration: 0.25),
            SignKeyframe(fist, duration: 0.2),
        ],

        // NO: Index and middle finger snap to thumb (like a beak closing).
        "no": [
            SignKeyframe(HandPose(
                thumb: FingerPose(curl: [open, open, open], spread: 0.3),
                index: straight(spread: 0.05),
                middle: straight(spread: -0.05),
                ring: curled(),
                pinky: curled()
            ), duration: 0.2),
            SignKeyframe(HandPose(
                thumb: FingerPose(curl: [half, half, open], spread: 0.0),
                index: FingerPose(curl: [half, half, open], spread: 0.05),
                middle: FingerPose(curl: [half, half, open], spread: -0.05),
                ring: curled(),
                pinky: curled()
            ), duration: 0.2),
            SignKeyframe(HandPose(
                thumb: FingerPose(curl: [open, open, open], spread: 0.3),
                index: straight(spread: 0.05),
                middle: straight(spread: -0.05),
                ring: curled(),
                pinky: curled()
            ), duration: 0.2),
        ],

        // THANK YOU: Flat hand moves away from the chin.
        "thank": [
            SignKeyframe(openHand.with(wrist: WristPose(pitch: -0.2)), duration: 0.3),
            SignKeyframe(openHand.with(wrist: WristPose(pitch: 0.3)), duration: 0.4),
        ],

        "you": [
            // Index finger points outward.
            SignKeyframe(HandPose(
                thumb: curled(spread: -0.1),
                index: straight(spread: 0.0),
                middle: curled(),
                ring: curled(),
                pinky: curled()
            ), duration: 0.3),
            SignKeyframe(HandPose(
                thumb: curled(spread: -0.1),
                index: straight(spread: 0.0),
                middle: curled(),
                ring: curled(),
                pinky: curled(),
                wrist: WristPose(pitch: 0.15)
            ), duration: 0.3),
        ],

        // PLEASE: Flat hand circles on the chest.
        "please": [
            SignKeyframe(openHand.with(wrist: WristPose(roll: -0.2)), duration: 0.3),
            SignKeyframe(openHand.with(wrist: WristPose(roll: 0.2, pitch: 0.1)), duration: 0.3),
            SignKeyframe(openHand.with(wrist: WristPose(roll: -0.2, pitch: -0.1)), duration: 0.3),
            SignKeyframe(openHand, duration: 0.2),
        ],

        // HELP: Fist on flat palm, both rise.
        "help": [
            SignKeyframe(HandPose(
                thumb: FingerPose(curl: [slight, open, open], spread: 0.5),
                index: straight(spread: 0.05),
                middle: straight(spread: 0.0),
                ring: straight(spread: -0.05),
                pinky: straight(spread: -0.1),
                wrist: WristPose(pitch: -0.3)
            ), duration: 0.3),
            SignKeyframe(HandPose(
                thumb: FingerPose(curl: [slight, open, open], spread: 0.5),
                index: straight(spread: 0.05),
                middle: straight(spread: 0.0),
                ring: straight(spread: -0.05),
                pinky: straight(spread: -0.1),
                wrist: WristPose(pitch: 0.2)
            ), duration: 0.4),
        ],

        // SORRY: Fist circles on the chest (A-handshape).
        "sorry": [
            SignKeyframe(fist.with(wrist: WristPose(roll: -0.2)), duration: 0.3),
            SignKeyframe(fist.with(wrist: WristPose(roll: 0.2, pitch: 0.1)), duration: 0.3),
            SignKeyframe(fist.with(wrist: WristPose(roll: -0.2, pitch: -0.1)), duration: 0.3),
            SignKeyframe(fist, duration: 0.2),
        ],

        // GOOD: Flat hand moves down from chin.
        "good": [
            SignKeyframe(openHand.with(wrist: WristPose(pitch: -0.2)), duration: 0.25),
            SignKeyframe(openHand.with(wrist: WristPose(pitch: 0.3)), duration: 0.35),
        ],

        // BAD: Flat hand moves away from chin, flipping down.
        "bad": [
            SignKeyframe(openHand.with(wrist: WristPose(pitch: -0.2)), duration: 0.25),
            SignKeyframe(openHand.with(wrist: WristPose(pitch: 0.5, roll: 0.3)), duration: 0.35),
        ],

        // LOVE: Arms crossed over chest, represented as fists crossed.
        "love": [
            SignKeyframe(fist.with(wrist: WristPose(roll: -0.3, pitch: -0.2)), duration: 0.3),
            SignKeyframe(fist.with(wrist: WristPose(roll: 0.0, pitch: 0.0)), duration: 0.4),
        ],

        // NAME: H-handshape taps twice (index and middle extended).
        "name": [
            SignKeyframe(HandPose(
                thumb: curled(spread: -0.1),
                index: straight(spread: 0.02),
                middle: straight(spread: -0.02),
                ring: curled(),
                pinky: curled(),
                wrist: WristPose(yaw: -0.3)
            ), duration: 0.25),
            SignKeyframe(HandPose(
                thumb: curled(spread: -0.1),
                index: straight(spread: 0.02),
                middle: straight(spread: -0.02),
                ring: curled(),
                pinky: curled(),
                wrist: WristPose(yaw: -0.3, pitch: 0.15)
            ), duration: 0.2),
            SignKeyframe(HandPose(
                thumb: curled(spread: -0.1),
                index: straight(spread: 0.02),
                middle: straight(spread: -0.02),
                ring: curled(),
                pinky: curled(),
                wrist: WristPose(yaw: -0.3)
            ), duration: 0.2),
        ],

        // MY/MINE: Flat hand presses against chest.
        "my": [
            SignKeyframe(openHand.with(wrist: WristPose(pitch: -0.1)), duration: 0.25),
            SignKeyframe(openHand.with(wrist: WristPose(pitch: 0.1)), duration: 0.25),
        ],

        // YOUR: Open palm pushes outward toward the other person.
        "your": [
            SignKeyframe(openHand, duration: 0.25),
            SignKeyframe(openHand.with(wrist: WristPose(pitch: 0.2)), duration: 0.3),
        ],

        // FRIEND: Index fingers hook together (X-handshapes interlock).
        "friend": [
            SignKeyframe(HandPose(
                thumb: curled(spread: -0.1),
                index: FingerPose(curl: [slight, full, slight], spread: 0),
                middle: curled(),
                ring: curled(),
                pinky: curled(),
                wrist: WristPose(roll: 0.3)
            ), duration: 0.3),
            SignKeyframe(HandPose(
                thumb: curled(spread: -0.1),
                index: FingerPose(curl: [slight, full, slight], spread: 0),
                middle: curled(),
                ring: curled(),
                pinky: curled(),
                wrist: WristPose(roll: -0.3)
            ), duration: 0.3),
        ],

        // LEARN: Flat hand to head, then pulls away closing into a fist.
        "learn": [
            SignKeyframe(openHand.with(wrist: WristPose(pitch: -0.3)), duration: 0.3),
            SignKeyframe(fist.with(wrist: WristPose(pitch: 0.1)), duration: 0.4),
        ],

        // UNDERSTAND: Index finger flicks up near the forehead.
        "understand": [
            SignKeyframe(HandPose(
                thumb: curled(spread: -0.1),
                index: curled(),
                middle: curled(),
                ring: curled(),
                pinky: curled()
            ), duration: 0.3),
            SignKeyframe(HandPose(
                thumb: curled(spread: -0.1),
                index: straight(),
                middle: curled(),
                ring: curled(),
                pinky: curled(),
                wrist: WristPose(pitch: -0.2)
            ), duration: 0.25),
        ],

        // SIGN (as in sign language): Both index fingers circle alternately.
        "sign": [
            SignKeyframe(HandPose(
                thumb: curled(spread: -0.1),
                index: straight(spread: 0.05),
                middle: curled(),
                ring: curled(),
                pinky: curled(),
                wrist: WristPose(roll: -0.3, pitch: -0.2)
            ), duration: 0.3),
            SignKeyframe(HandPose(
                thumb: curled(spread: -0.1),
                index: straight(spread: 0.05),
                middle: curled(),
                ring: curled(),
                pinky: curled(),
                wrist: WristPose(roll: 0.3, pitch: 0.2)
            ), duration: 0.3),
            SignKeyframe(HandPose(
                thumb: curled(spread: -0.1),
                index: straight(spread: 0.05),
                middle: curled(),
                ring: curled(),
                pinky: curled(),
                wrist: WristPose(roll: -0.3, pitch: -0.2)
            ), duration: 0.3),
        ],

        // WORLD: W-handshapes circle around each other.
        "world": [
            SignKeyframe(HandPose(
                thumb: FingerPose(curl: [half, half, open], spread: -0.15),
                index: straight(spread: 0.2),
                middle: straight(spread: 0.0),
                ring: straight(spread: -0.2),
                pinky: curled(),
                wrist: WristPose(roll: -0.3)
            ), duration: 0.3),
            SignKeyframe(HandPose(
                thumb: FingerPose(curl: [half, half, open], spread: -0.15),
                index: straight(spread: 0.2),
                middle: straight(spread: 0.0),
                ring: straight(spread: -0.2),
                pinky: curled(),
                wrist: WristPose(roll: 0.3)
            ), duration: 0.3),
        ],

        // WELCOME: Open hand sweeps inward (beckoning gesture).
        "welcome": [
            SignKeyframe(openHand.with(wrist: WristPose(yaw: 0.4)), duration: 0.3),
            SignKeyframe(openHand.with(wrist: WristPose(yaw: -0.1, pitch: 0.1)), duration: 0.4),
        ],

        // LANGUAGE: L-handshapes pull apart.
        "language": [
            SignKeyframe(HandPose(
                thumb: FingerPose(curl: [open, open, open], spread: 0.7),
                index: straight(spread: 0.05),
                middle: curled(),
                ring: curled(),
                pinky: curled(),
                wrist: WristPose(yaw: -0.2)
            ), duration: 0.3),
            SignKeyframe(HandPose(
                thumb: FingerPose(curl: [open, open, open], spread: 0.7),
                index: straight(spread: 0.05),
                middle: curled(),
                ring: curled(),
                pinky: curled(),
                wrist: WristPose(yaw: 0.2)
            ), duration: 0.3),
        ],
    ]

    /// Resolves a word to its sign keyframes.
    /// Returns a dedicated sign animation if one exists, otherwise fingerspells the word.
    static func keyframes(for word: String) -> [SignKeyframe] {
        let lowered = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
        if let sign = signs[lowered] {
            return sign
        }
        return ASLAlphabet.fingerspell(lowered)
    }

    /// Returns true if the word has a dedicated sign (not just fingerspelling).
    static func hasDedicatedSign(for word: String) -> Bool {
        signs[word.lowercased().trimmingCharacters(in: .punctuationCharacters)] != nil
    }
}

// MARK: - HandPose Convenience

extension HandPose {
    /// Returns a copy of this pose with a different wrist orientation.
    func with(wrist: WristPose) -> HandPose {
        var copy = self
        copy.wrist = wrist
        return copy
    }
}
