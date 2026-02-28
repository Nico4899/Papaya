//
//  HandModelBuilder.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 28.02.26.
//

import SceneKit

/// Builds a 3D hand model from SceneKit primitives (capsules and boxes).
///
/// The node hierarchy is:
/// ```
/// wristNode
///   ├── palmNode (flattened box)
///   ├── thumbBase → thumbMid → thumbTip
///   ├── indexBase → indexMid → indexTip
///   ├── middleBase → middleMid → middleTip
///   ├── ringBase → ringMid → ringTip
///   └── pinkyBase → pinkyMid → pinkyTip
/// ```
///
/// Each joint node's `eulerAngles.x` controls curl (flexion) and
/// the base node's `eulerAngles.z` controls spread (abduction).
final class HandModelBuilder {
    // MARK: - Geometry Constants

    /// Palm dimensions.
    private static let palmWidth: CGFloat = 0.8
    private static let palmHeight: CGFloat = 1.0
    private static let palmDepth: CGFloat = 0.2

    /// Finger segment lengths (proportional to a real hand).
    private static let fingerSegmentLengths: [String: [CGFloat]] = [
        "thumb":  [0.32, 0.28, 0.24],
        "index":  [0.38, 0.26, 0.20],
        "middle": [0.42, 0.28, 0.22],
        "ring":   [0.38, 0.26, 0.20],
        "pinky":  [0.30, 0.22, 0.18],
    ]

    /// Finger thickness (capsule radius).
    private static let fingerRadius: CGFloat = 0.06

    /// Where each finger attaches along the top edge of the palm.
    /// X positions from left (pinky) to right (index) when viewing palm-forward.
    private static let fingerAttachX: [String: Float] = [
        "thumb":  0.42,
        "index":  0.28,
        "middle": 0.08,
        "ring":  -0.12,
        "pinky": -0.32,
    ]

    /// The Y offset for finger attachment (top of the palm).
    private static let fingerAttachY: Float = 0.48

    /// Thumb attaches lower on the side of the palm.
    private static let thumbAttachY: Float = 0.15

    // MARK: - Materials

    /// A warm skin-tone material for the hand.
    private static func skinMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        // A neutral warm tone that looks good in both light and dark environments.
        material.diffuse.contents = UIColor(red: 0.87, green: 0.72, blue: 0.58, alpha: 1.0)
        material.roughness.contents = 0.6
        material.metalness.contents = 0.0
        material.lightingModel = .physicallyBased
        return material
    }

    /// A slightly darker material for the joints/knuckle lines.
    private static func jointMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.80, green: 0.65, blue: 0.52, alpha: 1.0)
        material.roughness.contents = 0.7
        material.metalness.contents = 0.0
        material.lightingModel = .physicallyBased
        return material
    }

    // MARK: - Build

    /// The names of the five fingers in the order they appear in `HandPose`.
    static let fingerNames = ["thumb", "index", "middle", "ring", "pinky"]

    /// Builds the complete hand model and returns the root wrist node.
    ///
    /// The returned node has named children following the pattern
    /// `"thumb_base"`, `"thumb_mid"`, `"thumb_tip"`, etc. so they can be
    /// looked up by name for animation.
    static func build() -> SCNNode {
        let wristNode = SCNNode()
        wristNode.name = "wrist"

        // MARK: Palm
        let palmGeometry = SCNBox(
            width: palmWidth,
            height: palmHeight,
            length: palmDepth,
            chamferRadius: 0.06
        )
        palmGeometry.materials = [skinMaterial()]
        let palmNode = SCNNode(geometry: palmGeometry)
        palmNode.name = "palm"
        wristNode.addChildNode(palmNode)

        // MARK: Fingers
        for fingerName in fingerNames {
            let segments = fingerSegmentLengths[fingerName] ?? [0.3, 0.25, 0.2]
            let attachX = fingerAttachX[fingerName] ?? 0
            let attachY = fingerName == "thumb" ? thumbAttachY : fingerAttachY
            let segmentNames = ["\(fingerName)_base", "\(fingerName)_mid", "\(fingerName)_tip"]

            // Build a chain of three segments.
            var parentNode = palmNode
            var currentY: Float = attachY

            for (i, segName) in segmentNames.enumerated() {
                let length = segments[i]

                // The joint node controls rotation. The visual segment hangs below it.
                let jointNode = SCNNode()
                jointNode.name = segName

                if fingerName == "thumb" && i == 0 {
                    // Thumb base attaches on the side of the palm, angled outward.
                    jointNode.position = SCNVector3(attachX, currentY, Float(palmDepth / 2) * 0.3)
                    jointNode.eulerAngles.z = 0.3 // Slight default outward angle.
                } else if i == 0 {
                    // Other fingers attach along the top edge.
                    jointNode.position = SCNVector3(attachX, currentY, 0)
                } else {
                    // Subsequent segments chain from the previous segment's tip.
                    let parentLength = segments[i - 1]
                    jointNode.position = SCNVector3(0, Float(parentLength), 0)
                }

                // The visual capsule for this finger segment.
                let capsule = SCNCapsule(capRadius: fingerRadius, height: length)
                capsule.materials = [i == 0 ? jointMaterial() : skinMaterial()]
                let capsuleNode = SCNNode(geometry: capsule)
                // Offset the capsule so its base sits at the joint pivot point.
                capsuleNode.position = SCNVector3(0, Float(length) / 2, 0)
                capsuleNode.name = "\(segName)_visual"

                jointNode.addChildNode(capsuleNode)
                parentNode.addChildNode(jointNode)
                parentNode = jointNode

                // Only the first segment needs the X offset tracked.
                if i == 0 {
                    currentY = 0 // Subsequent segments are relative.
                }
            }
        }

        return wristNode
    }

    // MARK: - Pose Application

    /// Applies a `HandPose` to an existing hand node hierarchy.
    ///
    /// - Parameters:
    ///   - handNode: The root wrist node built by `build()`.
    ///   - pose: The target hand pose.
    ///   - duration: Animation duration in seconds. Use 0 for immediate (no animation).
    static func applyPose(to handNode: SCNNode, pose: HandPose, duration: TimeInterval = 0) {
        // Apply wrist rotation.
        let wristAngles = SCNVector3(pose.wrist.pitch, pose.wrist.yaw, pose.wrist.roll)

        // Collect all the finger data to apply.
        let fingerData: [(name: String, pose: FingerPose)] = [
            ("thumb", pose.thumb),
            ("index", pose.index),
            ("middle", pose.middle),
            ("ring", pose.ring),
            ("pinky", pose.pinky),
        ]

        if duration > 0 {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = duration
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        }

        handNode.eulerAngles = wristAngles

        for (name, fingerPose) in fingerData {
            let segmentNames = ["\(name)_base", "\(name)_mid", "\(name)_tip"]
            for (i, segName) in segmentNames.enumerated() {
                guard let jointNode = handNode.childNode(withName: segName, recursively: true) else {
                    continue
                }
                // Curl is applied as rotation around the X axis (flexion).
                jointNode.eulerAngles.x = -fingerPose.curl[i]
                // Spread is applied only to the base joint as rotation around Z.
                if i == 0 {
                    jointNode.eulerAngles.z = fingerPose.spread
                }
            }
        }

        if duration > 0 {
            SCNTransaction.commit()
        }
    }
}
