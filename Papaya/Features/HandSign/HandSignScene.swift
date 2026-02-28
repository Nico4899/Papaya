//
//  HandSignScene.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 28.02.26.
//

import SceneKit
import OSLog

/// A SceneKit scene that contains a 3D hand model with camera and lighting,
/// and provides methods to animate the hand through sign language poses.
final class HandSignScene: SCNScene {
    /// The root hand node (wrist).
    let handNode: SCNNode

    /// The camera node, positioned to frame the hand nicely.
    let cameraNode: SCNNode

    /// Called when the animation sequence advances to a new word.
    var onWordChanged: ((Int) -> Void)?

    /// Called when the entire sequence finishes playing.
    var onSequenceComplete: (() -> Void)?

    private var animationTimer: Timer?
    private var currentKeyframes: [SignKeyframe] = []
    private var currentKeyframeIndex = 0

    override init() {
        // Build the hand model.
        handNode = HandModelBuilder.build()
        cameraNode = SCNNode()

        super.init()

        // Add the hand to the scene.
        rootNode.addChildNode(handNode)
        // Position the hand slightly below center so fingers extend upward naturally.
        handNode.position = SCNVector3(0, -0.3, 0)

        // MARK: Camera Setup
        let camera = SCNCamera()
        camera.usesOrthographicProjection = false
        camera.fieldOfView = 40
        camera.zNear = 0.1
        camera.zFar = 50
        cameraNode.camera = camera
        // Position the camera in front of the hand, slightly above center.
        cameraNode.position = SCNVector3(0, 0.5, 3.5)
        cameraNode.look(at: SCNVector3(0, 0.2, 0))
        rootNode.addChildNode(cameraNode)

        // MARK: Lighting
        setupLighting()

        // Apply the resting pose.
        HandModelBuilder.applyPose(to: handNode, pose: .rest)

        // Set a neutral background color.
        background.contents = UIColor.clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lighting

    private func setupLighting() {
        // Key light: a warm directional light from the upper right.
        let keyLight = SCNLight()
        keyLight.type = .directional
        keyLight.intensity = 800
        keyLight.color = UIColor(white: 1.0, alpha: 1.0)
        keyLight.castsShadow = true
        keyLight.shadowRadius = 4
        keyLight.shadowSampleCount = 8
        let keyLightNode = SCNNode()
        keyLightNode.light = keyLight
        keyLightNode.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 6, 0)
        rootNode.addChildNode(keyLightNode)

        // Fill light: a softer light from the left to reduce harsh shadows.
        let fillLight = SCNLight()
        fillLight.type = .directional
        fillLight.intensity = 400
        fillLight.color = UIColor(red: 0.9, green: 0.92, blue: 1.0, alpha: 1.0)
        let fillLightNode = SCNNode()
        fillLightNode.light = fillLight
        fillLightNode.eulerAngles = SCNVector3(-Float.pi / 6, -Float.pi / 4, 0)
        rootNode.addChildNode(fillLightNode)

        // Ambient light: ensures no part of the hand is completely black.
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 300
        ambientLight.color = UIColor(white: 0.8, alpha: 1.0)
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        rootNode.addChildNode(ambientNode)
    }

    // MARK: - Single Pose Animation

    /// Animates the hand to a single target pose.
    func animateTo(pose: HandPose, duration: TimeInterval = 0.3) {
        HandModelBuilder.applyPose(to: handNode, pose: pose, duration: duration)
    }

    /// Immediately sets the hand to a pose without animation.
    func setPose(_ pose: HandPose) {
        HandModelBuilder.applyPose(to: handNode, pose: pose, duration: 0)
    }

    // MARK: - Sequence Playback

    /// Plays a sequence of keyframes one after another.
    /// Each keyframe specifies the target pose and the transition duration.
    func playSequence(_ keyframes: [SignKeyframe], speed: Float = 1.0) {
        stopSequence()

        guard !keyframes.isEmpty else {
            onSequenceComplete?()
            return
        }

        currentKeyframes = keyframes
        currentKeyframeIndex = 0

        // Start animating to the first keyframe.
        advanceToNextKeyframe(speed: speed)
    }

    /// Stops any running animation sequence.
    func stopSequence() {
        animationTimer?.invalidate()
        animationTimer = nil
        currentKeyframes = []
        currentKeyframeIndex = 0
    }

    /// Advances to the next keyframe in the current sequence.
    private func advanceToNextKeyframe(speed: Float) {
        guard currentKeyframeIndex < currentKeyframes.count else {
            // Sequence is complete.
            onSequenceComplete?()
            return
        }

        let keyframe = currentKeyframes[currentKeyframeIndex]
        let adjustedDuration = TimeInterval(Float(keyframe.duration) / max(speed, 0.1))

        // Animate to this keyframe's pose.
        animateTo(pose: keyframe.pose, duration: adjustedDuration * 0.7)

        // Schedule the next keyframe after this one's full duration.
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(
            withTimeInterval: adjustedDuration,
            repeats: false
        ) { [weak self] _ in
            guard let self else { return }
            self.currentKeyframeIndex += 1
            self.advanceToNextKeyframe(speed: speed)
        }
    }

    // MARK: - Multi-Word Playback

    /// Plays a sequence of words, resolving each to keyframes via `ASLSignLibrary`.
    /// Calls `onWordChanged` with the word index as each word begins animating.
    func playWords(_ words: [String], speed: Float = 1.0, startIndex: Int = 0, onComplete: (() -> Void)? = nil) {
        guard startIndex < words.count else {
            onComplete?()
            return
        }

        let word = words[startIndex]
        let keyframes = ASLSignLibrary.keyframes(for: word)

        Logger.ui.info("Playing sign for word '\(word)' (\(keyframes.count) keyframes)")
        onWordChanged?(startIndex)

        // Set up the completion to chain into the next word.
        // Add a brief pause between words.
        currentKeyframes = keyframes
        currentKeyframeIndex = 0

        playSequenceInternal(keyframes, speed: speed) { [weak self] in
            // Brief pause between words, then advance to the next.
            let pauseDuration = TimeInterval(0.25 / max(speed, 0.1))
            self?.animationTimer = Timer.scheduledTimer(
                withTimeInterval: pauseDuration,
                repeats: false
            ) { [weak self] _ in
                self?.playWords(words, speed: speed, startIndex: startIndex + 1, onComplete: onComplete)
            }
        }
    }

    /// Internal helper: plays keyframes with a completion callback.
    private func playSequenceInternal(_ keyframes: [SignKeyframe], speed: Float, completion: @escaping () -> Void) {
        guard !keyframes.isEmpty else {
            completion()
            return
        }

        currentKeyframes = keyframes
        currentKeyframeIndex = 0

        advanceToNextKeyframeInternal(speed: speed, completion: completion)
    }

    private func advanceToNextKeyframeInternal(speed: Float, completion: @escaping () -> Void) {
        guard currentKeyframeIndex < currentKeyframes.count else {
            completion()
            return
        }

        let keyframe = currentKeyframes[currentKeyframeIndex]
        let adjustedDuration = TimeInterval(Float(keyframe.duration) / max(speed, 0.1))

        animateTo(pose: keyframe.pose, duration: adjustedDuration * 0.7)

        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(
            withTimeInterval: adjustedDuration,
            repeats: false
        ) { [weak self] _ in
            guard let self else { return }
            self.currentKeyframeIndex += 1
            self.advanceToNextKeyframeInternal(speed: speed, completion: completion)
        }
    }
}
