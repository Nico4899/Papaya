//
//  HandSignView.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 28.02.26.
//

import SwiftUI
import SceneKit

/// A SwiftUI view that wraps an `SCNView` to display the 3D hand sign model.
///
/// This view renders the `HandSignScene` and is designed to be embedded in
/// the translator playback view and library item previews.
struct HandSignView: UIViewRepresentable {
    /// The scene containing the 3D hand model.
    let scene: HandSignScene

    /// Whether to allow the user to rotate/zoom the camera interactively.
    var allowsCameraControl: Bool = false

    /// Background color for the SceneKit view. Use `.clear` for transparency.
    var backgroundColor: UIColor = .clear

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.pointOfView = scene.cameraNode
        scnView.allowsCameraControl = allowsCameraControl
        scnView.autoenablesDefaultLighting = false
        scnView.backgroundColor = backgroundColor
        scnView.antialiasingMode = .multisampling4X
        // Render continuously for smooth animations.
        scnView.rendersContinuously = true
        scnView.isAccessibilityElement = true
        scnView.accessibilityTraits = .image
        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = scene
        scnView.pointOfView = scene.cameraNode
        scnView.allowsCameraControl = allowsCameraControl
        scnView.backgroundColor = backgroundColor
    }
}

// MARK: - Convenience Initializer for Static Pose Preview

extension HandSignView {
    /// Creates a `HandSignView` showing a single static pose (useful for thumbnails).
    init(pose: HandPose, allowsCameraControl: Bool = false, backgroundColor: UIColor = .clear) {
        let scene = HandSignScene()
        scene.setPose(pose)
        self.init(scene: scene, allowsCameraControl: allowsCameraControl, backgroundColor: backgroundColor)
    }

    /// Creates a `HandSignView` showing the first frame of a word's sign.
    init(word: String, allowsCameraControl: Bool = false, backgroundColor: UIColor = .clear) {
        let scene = HandSignScene()
        let keyframes = ASLSignLibrary.keyframes(for: word)
        if let firstPose = keyframes.first?.pose {
            scene.setPose(firstPose)
        }
        self.init(scene: scene, allowsCameraControl: allowsCameraControl, backgroundColor: backgroundColor)
    }
}

#Preview("Static Pose - Hello") {
    HandSignView(
        pose: ASLAlphabet.pose(for: "A")
    )
    .frame(width: 300, height: 400)
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 20))
}

#Preview("Word Preview") {
    HandSignView(word: "hello")
        .frame(width: 300, height: 400)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
}
