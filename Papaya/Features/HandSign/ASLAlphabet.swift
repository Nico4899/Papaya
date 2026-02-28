//
//  ASLAlphabet.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 28.02.26.
//

import Foundation

/// Static hand pose data for the American Sign Language (ASL) manual alphabet.
///
/// Each letter maps to a `HandPose` that approximates the canonical ASL handshape.
/// Joint angles are defined in radians, where:
/// - Curl 0 = fully extended, ~π/2 = fully curled
/// - Spread positive = finger moves away from center, negative = toward center
///
/// Reference: Adapted from ASL fingerspelling chart conventions.
enum ASLAlphabet {
    // Shorthand constants for readability.
    private static let open: Float = 0.0
    private static let slight: Float = 0.2
    private static let half: Float = 0.7
    private static let full: Float = 1.45  // ~83°

    // Convenience to build a curled-shut finger.
    private static func curled(spread: Float = 0) -> FingerPose {
        FingerPose(curl: [full, full, full], spread: spread)
    }

    // Convenience for a straight, extended finger.
    private static func straight(spread: Float = 0) -> FingerPose {
        FingerPose(curl: [open, open, open], spread: spread)
    }

    // Convenience for a finger with only the MCP bent (hooked at the knuckle).
    private static func hooked(spread: Float = 0) -> FingerPose {
        FingerPose(curl: [half, open, open], spread: spread)
    }

    /// Dictionary mapping each uppercase letter to its ASL hand pose.
    static let poses: [Character: HandPose] = [
        // A: Fist with thumb resting on the side of the index finger.
        "A": HandPose(
            thumb: FingerPose(curl: [slight, open, open], spread: 0.1),
            index: curled(),
            middle: curled(),
            ring: curled(),
            pinky: curled()
        ),

        // B: Flat hand, fingers together and extended, thumb tucked across palm.
        "B": HandPose(
            thumb: FingerPose(curl: [full, half, open], spread: -0.2),
            index: straight(),
            middle: straight(),
            ring: straight(),
            pinky: straight()
        ),

        // C: Hand curved into a C shape, like holding a cup.
        "C": HandPose(
            thumb: FingerPose(curl: [slight, open, open], spread: 0.5),
            index: FingerPose(curl: [half, half, slight], spread: 0.1),
            middle: FingerPose(curl: [half, half, slight], spread: 0.0),
            ring: FingerPose(curl: [half, half, slight], spread: -0.05),
            pinky: FingerPose(curl: [half, half, slight], spread: -0.1)
        ),

        // D: Index finger points up, other fingers curled, thumb touches middle finger tip.
        "D": HandPose(
            thumb: FingerPose(curl: [half, slight, open], spread: -0.1),
            index: straight(spread: 0.05),
            middle: curled(),
            ring: curled(),
            pinky: curled()
        ),

        // E: All fingers curled, thumb tucked under fingertips.
        "E": HandPose(
            thumb: FingerPose(curl: [half, half, open], spread: -0.1),
            index: FingerPose(curl: [full, half, half], spread: 0),
            middle: FingerPose(curl: [full, half, half], spread: 0),
            ring: FingerPose(curl: [full, half, half], spread: 0),
            pinky: FingerPose(curl: [full, half, half], spread: -0.05)
        ),

        // F: Thumb and index form a circle, other fingers extended and spread.
        "F": HandPose(
            thumb: FingerPose(curl: [half, half, open], spread: -0.2),
            index: FingerPose(curl: [full, full, slight], spread: 0),
            middle: straight(spread: 0.1),
            ring: straight(spread: 0.0),
            pinky: straight(spread: -0.1)
        ),

        // G: Index finger points sideways, thumb parallel, other fingers curled.
        "G": HandPose(
            thumb: FingerPose(curl: [slight, open, open], spread: 0.1),
            index: straight(spread: 0.05),
            middle: curled(),
            ring: curled(),
            pinky: curled(),
            wrist: WristPose(yaw: -0.5)
        ),

        // H: Index and middle fingers point sideways together, others curled.
        "H": HandPose(
            thumb: FingerPose(curl: [half, slight, open], spread: -0.1),
            index: straight(spread: 0.05),
            middle: straight(spread: -0.05),
            ring: curled(),
            pinky: curled(),
            wrist: WristPose(yaw: -0.5)
        ),

        // I: Pinky extended, other fingers curled in a fist, thumb over fingers.
        "I": HandPose(
            thumb: FingerPose(curl: [half, slight, open], spread: -0.1),
            index: curled(),
            middle: curled(),
            ring: curled(),
            pinky: straight(spread: -0.1)
        ),

        // J: Like I but with a downward J-motion (wrist roll). Static pose is same as I.
        "J": HandPose(
            thumb: FingerPose(curl: [half, slight, open], spread: -0.1),
            index: curled(),
            middle: curled(),
            ring: curled(),
            pinky: straight(spread: -0.1),
            wrist: WristPose(roll: 0.3)
        ),

        // K: Index finger up, middle finger angled forward, thumb between them.
        "K": HandPose(
            thumb: FingerPose(curl: [slight, open, open], spread: 0.1),
            index: straight(spread: 0.15),
            middle: FingerPose(curl: [half, open, open], spread: -0.05),
            ring: curled(),
            pinky: curled()
        ),

        // L: Thumb and index form an L shape, others curled.
        "L": HandPose(
            thumb: FingerPose(curl: [open, open, open], spread: 0.7),
            index: straight(spread: 0.05),
            middle: curled(),
            ring: curled(),
            pinky: curled()
        ),

        // M: Three fingers (index, middle, ring) wrap over the thumb.
        "M": HandPose(
            thumb: FingerPose(curl: [full, half, open], spread: -0.1),
            index: FingerPose(curl: [full, full, half], spread: 0.05),
            middle: FingerPose(curl: [full, full, half], spread: 0),
            ring: FingerPose(curl: [full, full, half], spread: -0.05),
            pinky: curled()
        ),

        // N: Two fingers (index, middle) wrap over the thumb.
        "N": HandPose(
            thumb: FingerPose(curl: [full, half, open], spread: -0.1),
            index: FingerPose(curl: [full, full, half], spread: 0.05),
            middle: FingerPose(curl: [full, full, half], spread: -0.05),
            ring: curled(),
            pinky: curled()
        ),

        // O: All fingertips touch the thumb, forming an O shape.
        "O": HandPose(
            thumb: FingerPose(curl: [half, slight, open], spread: 0.1),
            index: FingerPose(curl: [full, half, slight], spread: 0.05),
            middle: FingerPose(curl: [full, half, slight], spread: 0),
            ring: FingerPose(curl: [full, half, slight], spread: -0.05),
            pinky: FingerPose(curl: [full, half, slight], spread: -0.1)
        ),

        // P: Like K but with wrist pointing down.
        "P": HandPose(
            thumb: FingerPose(curl: [slight, open, open], spread: 0.1),
            index: straight(spread: 0.15),
            middle: FingerPose(curl: [half, open, open], spread: -0.05),
            ring: curled(),
            pinky: curled(),
            wrist: WristPose(pitch: 0.8)
        ),

        // Q: Like G but with wrist pointing down (thumb and index pinch downward).
        "Q": HandPose(
            thumb: FingerPose(curl: [slight, open, open], spread: 0.1),
            index: straight(spread: 0.05),
            middle: curled(),
            ring: curled(),
            pinky: curled(),
            wrist: WristPose(pitch: 0.8)
        ),

        // R: Index and middle crossed, others curled.
        "R": HandPose(
            thumb: FingerPose(curl: [half, slight, open], spread: -0.1),
            index: straight(spread: -0.15),
            middle: straight(spread: 0.15),
            ring: curled(),
            pinky: curled()
        ),

        // S: Fist with thumb wrapped over the front of the fingers.
        "S": HandPose(
            thumb: FingerPose(curl: [half, half, open], spread: -0.1),
            index: curled(),
            middle: curled(),
            ring: curled(),
            pinky: curled()
        ),

        // T: Thumb tucked between index and middle fingers, fist closed.
        "T": HandPose(
            thumb: FingerPose(curl: [full, slight, open], spread: -0.15),
            index: FingerPose(curl: [full, full, half], spread: 0.05),
            middle: curled(),
            ring: curled(),
            pinky: curled()
        ),

        // U: Index and middle fingers extended together, others curled.
        "U": HandPose(
            thumb: FingerPose(curl: [half, slight, open], spread: -0.1),
            index: straight(spread: -0.02),
            middle: straight(spread: 0.02),
            ring: curled(),
            pinky: curled()
        ),

        // V: Index and middle fingers extended and spread apart (peace sign).
        "V": HandPose(
            thumb: FingerPose(curl: [half, slight, open], spread: -0.1),
            index: straight(spread: 0.2),
            middle: straight(spread: -0.2),
            ring: curled(),
            pinky: curled()
        ),

        // W: Index, middle, and ring fingers extended and spread.
        "W": HandPose(
            thumb: FingerPose(curl: [half, half, open], spread: -0.15),
            index: straight(spread: 0.2),
            middle: straight(spread: 0.0),
            ring: straight(spread: -0.2),
            pinky: curled()
        ),

        // X: Index finger hooked (bent at PIP), others curled.
        "X": HandPose(
            thumb: FingerPose(curl: [half, slight, open], spread: -0.1),
            index: FingerPose(curl: [slight, full, slight], spread: 0),
            middle: curled(),
            ring: curled(),
            pinky: curled()
        ),

        // Y: Thumb and pinky extended, others curled (shaka/hang loose).
        "Y": HandPose(
            thumb: FingerPose(curl: [open, open, open], spread: 0.7),
            index: curled(),
            middle: curled(),
            ring: curled(),
            pinky: straight(spread: -0.2)
        ),

        // Z: Index finger traces a Z in the air. Static pose is index pointing.
        "Z": HandPose(
            thumb: FingerPose(curl: [half, slight, open], spread: -0.1),
            index: straight(spread: 0.05),
            middle: curled(),
            ring: curled(),
            pinky: curled()
        ),
    ]

    /// Returns the hand pose for a given character, case-insensitive.
    /// Returns `HandPose.rest` for non-letter characters (spaces, punctuation).
    static func pose(for character: Character) -> HandPose {
        poses[Character(character.uppercased())] ?? .rest
    }

    /// Converts a word into a sequence of `SignKeyframe`s for fingerspelling.
    /// Each letter holds for `letterDuration` seconds.
    static func fingerspell(_ word: String, letterDuration: TimeInterval = 0.4) -> [SignKeyframe] {
        word.uppercased().map { char in
            SignKeyframe(pose(for: char), duration: letterDuration)
        }
    }
}
