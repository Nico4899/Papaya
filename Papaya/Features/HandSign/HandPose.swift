//
//  HandPose.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 28.02.26.
//

import Foundation
import simd

/// Represents the complete pose of a hand by specifying the curl (flexion)
/// and spread (abduction) of each finger, plus wrist orientation.
///
/// All angles are in radians. Curl values go from 0 (fully extended) to
/// approximately π/2 (fully curled). Spread values go from negative (adducted/
/// crossed inward) to positive (spread apart).
struct HandPose: Equatable, Sendable {
    var thumb: FingerPose
    var index: FingerPose
    var middle: FingerPose
    var ring: FingerPose
    var pinky: FingerPose
    var wrist: WristPose

    /// Linearly interpolates between two hand poses for smooth animation.
    func interpolated(to target: HandPose, progress: Float) -> HandPose {
        HandPose(
            thumb: thumb.interpolated(to: target.thumb, progress: progress),
            index: index.interpolated(to: target.index, progress: progress),
            middle: middle.interpolated(to: target.middle, progress: progress),
            ring: ring.interpolated(to: target.ring, progress: progress),
            pinky: pinky.interpolated(to: target.pinky, progress: progress),
            wrist: wrist.interpolated(to: target.wrist, progress: progress)
        )
    }

    /// A neutral, relaxed hand with fingers slightly curled.
    static let rest = HandPose(
        thumb: FingerPose(curl: [0.1, 0.05, 0.05], spread: 0.3),
        index: FingerPose(curl: [0.2, 0.15, 0.1], spread: 0.05),
        middle: FingerPose(curl: [0.2, 0.15, 0.1], spread: 0.0),
        ring: FingerPose(curl: [0.2, 0.15, 0.1], spread: -0.05),
        pinky: FingerPose(curl: [0.25, 0.2, 0.1], spread: -0.1)
    )
}

/// Represents the pose of a single finger.
///
/// Each finger has three joints that curl (flex):
/// - `curl[0]`: MCP — the knuckle joint where the finger meets the palm
/// - `curl[1]`: PIP — the middle joint of the finger
/// - `curl[2]`: DIP — the fingertip joint
///
/// `spread` controls lateral movement (abduction/adduction) at the MCP joint.
struct FingerPose: Equatable, Sendable {
    /// Curl angles for MCP, PIP, and DIP joints (in radians).
    var curl: [Float]
    /// Lateral spread at the MCP joint (in radians).
    var spread: Float

    init(curl: [Float] = [0, 0, 0], spread: Float = 0) {
        // Ensure exactly three curl values exist.
        var padded = curl
        while padded.count < 3 { padded.append(0) }
        self.curl = Array(padded.prefix(3))
        self.spread = spread
    }

    func interpolated(to target: FingerPose, progress: Float) -> FingerPose {
        FingerPose(
            curl: zip(curl, target.curl).map { mix($0, $1, t: progress) },
            spread: mix(spread, target.spread, t: progress)
        )
    }
}

/// Represents the wrist orientation as Euler angles (pitch, yaw, roll).
struct WristPose: Equatable, Sendable {
    /// Forward/backward tilt (flexion/extension).
    var pitch: Float
    /// Left/right rotation (radial/ulnar deviation).
    var yaw: Float
    /// Clockwise/counterclockwise twist (pronation/supination).
    var roll: Float

    init(pitch: Float = 0, yaw: Float = 0, roll: Float = 0) {
        self.pitch = pitch
        self.yaw = yaw
        self.roll = roll
    }

    func interpolated(to target: WristPose, progress: Float) -> WristPose {
        WristPose(
            pitch: mix(pitch, target.pitch, t: progress),
            yaw: mix(yaw, target.yaw, t: progress),
            roll: mix(roll, target.roll, t: progress)
        )
    }
}

// Default wrist pose for HandPose initializers that omit it.
extension HandPose {
    init(thumb: FingerPose, index: FingerPose, middle: FingerPose, ring: FingerPose, pinky: FingerPose) {
        self.thumb = thumb
        self.index = index
        self.middle = middle
        self.ring = ring
        self.pinky = pinky
        self.wrist = WristPose()
    }
}

/// A keyframe in a sign animation sequence, pairing a hand pose with a
/// duration that controls how long the transition to this pose takes.
struct SignKeyframe: Equatable, Sendable {
    let pose: HandPose
    /// Duration in seconds to animate from the previous pose to this one.
    let duration: TimeInterval

    init(_ pose: HandPose, duration: TimeInterval = 0.3) {
        self.pose = pose
        self.duration = duration
    }
}

// MARK: - Helpers

/// Linear interpolation between two scalar values.
private func mix(_ a: Float, _ b: Float, t: Float) -> Float {
    a + (b - a) * t
}
