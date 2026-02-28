//
//  HandPoseDetector.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 28.02.26.
//

import Foundation
import Vision
import AVFoundation
import OSLog

/// Detects hand poses from camera frames using Apple's Vision framework
/// (`VNDetectHumanHandPoseRequest`) and converts them into `HandPose` values
/// that can be compared against the ASL reference data.
///
/// All detection happens on-device — no network connection required.
@Observable
final class HandPoseDetector: NSObject {
    // MARK: - Public State

    /// The most recently detected hand pose, or nil if no hand is visible.
    var detectedPose: HandPose?

    /// The raw Vision observation for drawing hand landmark overlays.
    var detectedObservation: VNHumanHandPoseObservation?

    /// Whether a hand is currently detected in the camera frame.
    var isHandDetected: Bool { detectedPose != nil }

    /// The similarity score (0.0–1.0) between the detected pose and a reference pose.
    var matchScore: Float = 0

    /// The reference pose to compare against.
    var referencePose: HandPose?

    // MARK: - Camera Session

    /// The capture session for the front-facing camera.
    let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let processingQueue = DispatchQueue(label: "com.papaya.handpose", qos: .userInteractive)

    // MARK: - Vision

    private let handPoseRequest: VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        // Only track one hand at a time for simplicity.
        request.maximumHandCount = 1
        return request
    }()

    // MARK: - Setup

    /// Configures the camera session for hand pose detection.
    func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .medium

        // Use the front-facing camera so the user can see themselves.
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            Logger.camera.error("Front camera not available for hand pose detection.")
            captureSession.commitConfiguration()
            return
        }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        videoOutput.setSampleBufferDelegate(self, queue: processingQueue)
        // Discard late frames to keep detection responsive.
        videoOutput.alwaysDiscardsLateVideoFrames = true

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        // Mirror the video so it feels natural (like a mirror).
        if let connection = videoOutput.connection(with: .video) {
            connection.isVideoMirrored = true
        }

        captureSession.commitConfiguration()
    }

    /// Starts the camera session on a background thread.
    func startSession() {
        processingQueue.async { [weak self] in
            guard let self, !self.captureSession.isRunning else { return }
            self.captureSession.startRunning()
            Logger.camera.info("Hand pose detection session started.")
        }
    }

    /// Stops the camera session.
    func stopSession() {
        processingQueue.async { [weak self] in
            guard let self, self.captureSession.isRunning else { return }
            self.captureSession.stopRunning()
            Logger.camera.info("Hand pose detection session stopped.")
        }
    }

    // MARK: - Comparison

    /// Computes the similarity between two hand poses (0.0 = completely different, 1.0 = identical).
    ///
    /// The comparison uses the mean absolute difference of all finger curl values
    /// and spread angles, normalized to a 0–1 range.
    static func similarity(between a: HandPose, and b: HandPose) -> Float {
        let fingerPairs: [(FingerPose, FingerPose)] = [
            (a.thumb, b.thumb),
            (a.index, b.index),
            (a.middle, b.middle),
            (a.ring, b.ring),
            (a.pinky, b.pinky),
        ]

        var totalDifference: Float = 0
        var count: Float = 0

        for (fa, fb) in fingerPairs {
            // Compare curl values for all three joints.
            for i in 0..<3 {
                totalDifference += abs(fa.curl[i] - fb.curl[i])
                count += 1
            }
            // Compare spread.
            totalDifference += abs(fa.spread - fb.spread)
            count += 1
        }

        // Wrist comparison.
        totalDifference += abs(a.wrist.pitch - b.wrist.pitch)
        totalDifference += abs(a.wrist.yaw - b.wrist.yaw)
        totalDifference += abs(a.wrist.roll - b.wrist.roll)
        count += 3

        // Normalize: the maximum possible difference per value is ~π/2 ≈ 1.57.
        let maxDiffPerValue: Float = 1.57
        let normalizedDiff = totalDifference / (count * maxDiffPerValue)

        // Convert to similarity (1 = perfect match, 0 = completely off).
        return max(0, 1 - normalizedDiff)
    }

    // MARK: - Vision → HandPose Conversion

    /// Converts a Vision hand pose observation into our `HandPose` model.
    ///
    /// Maps detected joint positions to estimated curl and spread angles.
    /// This is an approximation — Vision provides 2D landmark positions,
    /// not joint angles, so we estimate curl from relative finger segment distances.
    private func convertToHandPose(_ observation: VNHumanHandPoseObservation) -> HandPose? {
        do {
            let thumb = try extractFingerPose(
                observation: observation,
                tip: .thumbTip, dip: .thumbIP, pip: .thumbMP, mcp: .thumbCMC
            )
            let index = try extractFingerPose(
                observation: observation,
                tip: .indexTip, dip: .indexDIP, pip: .indexPIP, mcp: .indexMCP
            )
            let middle = try extractFingerPose(
                observation: observation,
                tip: .middleTip, dip: .middleDIP, pip: .middlePIP, mcp: .middleMCP
            )
            let ring = try extractFingerPose(
                observation: observation,
                tip: .ringTip, dip: .ringDIP, pip: .ringPIP, mcp: .ringMCP
            )
            let pinky = try extractFingerPose(
                observation: observation,
                tip: .littleTip, dip: .littleDIP, pip: .littlePIP, mcp: .littleMCP
            )

            let wristPoint = try observation.recognizedPoint(.wrist)
            let middleMCP = try observation.recognizedPoint(.middleMCP)

            // Estimate wrist orientation from the angle between the wrist and middle MCP.
            let dx = Float(middleMCP.location.x - wristPoint.location.x)
            let dy = Float(middleMCP.location.y - wristPoint.location.y)
            let wristAngle = atan2(dx, dy)

            return HandPose(
                thumb: thumb,
                index: index,
                middle: middle,
                ring: ring,
                pinky: pinky,
                wrist: WristPose(pitch: 0, yaw: wristAngle, roll: 0)
            )
        } catch {
            Logger.data.error("Failed to extract hand pose: \(error.localizedDescription)")
            return nil
        }
    }

    /// Estimates a `FingerPose` from four Vision landmark points.
    ///
    /// Curl is estimated by how close the fingertip is to the MCP (knuckle).
    /// When the finger is fully extended, the tip is far from the MCP;
    /// when curled, the tip is close.
    private func extractFingerPose(
        observation: VNHumanHandPoseObservation,
        tip: VNHumanHandPoseObservation.JointName,
        dip: VNHumanHandPoseObservation.JointName,
        pip: VNHumanHandPoseObservation.JointName,
        mcp: VNHumanHandPoseObservation.JointName
    ) throws -> FingerPose {
        let tipPoint = try observation.recognizedPoint(tip)
        let dipPoint = try observation.recognizedPoint(dip)
        let pipPoint = try observation.recognizedPoint(pip)
        let mcpPoint = try observation.recognizedPoint(mcp)

        // Skip low-confidence detections.
        guard tipPoint.confidence > 0.3 && mcpPoint.confidence > 0.3 else {
            return FingerPose()
        }

        // Estimate curl for each joint by measuring the angle formed.
        let mcpCurl = estimateJointAngle(
            parent: mcpPoint.location,
            joint: pipPoint.location,
            child: dipPoint.location
        )
        let pipCurl = estimateJointAngle(
            parent: pipPoint.location,
            joint: dipPoint.location,
            child: tipPoint.location
        )

        // DIP curl estimated from how close the tip is to the DIP.
        let tipDist = distance(tipPoint.location, dipPoint.location)
        let dipCurl = Float(max(0, 1 - tipDist * 8)) * 1.45

        // Spread: horizontal offset of the fingertip from the MCP.
        let spread = Float(tipPoint.location.x - mcpPoint.location.x) * 3.0

        return FingerPose(
            curl: [mcpCurl, pipCurl, dipCurl],
            spread: spread
        )
    }

    /// Estimates the curl angle at a joint from three 2D points.
    /// Returns a value in radians (0 = straight, ~π/2 = fully curled).
    private func estimateJointAngle(parent: CGPoint, joint: CGPoint, child: CGPoint) -> Float {
        let v1 = CGPoint(x: parent.x - joint.x, y: parent.y - joint.y)
        let v2 = CGPoint(x: child.x - joint.x, y: child.y - joint.y)

        let dot = v1.x * v2.x + v1.y * v2.y
        let mag1 = sqrt(v1.x * v1.x + v1.y * v1.y)
        let mag2 = sqrt(v2.x * v2.x + v2.y * v2.y)

        guard mag1 > 0 && mag2 > 0 else { return 0 }

        let cosAngle = max(-1, min(1, dot / (mag1 * mag2)))
        let angle = acos(cosAngle)

        // The angle between segments: π = straight, 0 = fully folded.
        // Convert to curl: 0 = straight, π/2 = fully curled.
        return Float(max(0, .pi - angle))
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y))
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension HandPoseDetector: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])

        do {
            try handler.perform([handPoseRequest])

            guard let observation = handPoseRequest.results?.first else {
                DispatchQueue.main.async { [weak self] in
                    self?.detectedPose = nil
                    self?.detectedObservation = nil
                    self?.matchScore = 0
                }
                return
            }

            let pose = convertToHandPose(observation)

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.detectedPose = pose
                self.detectedObservation = observation

                // Compute match score if we have both a detected pose and a reference.
                if let detected = pose, let reference = self.referencePose {
                    self.matchScore = HandPoseDetector.similarity(between: detected, and: reference)
                } else {
                    self.matchScore = 0
                }
            }
        } catch {
            Logger.data.error("Vision hand pose request failed: \(error.localizedDescription)")
        }
    }
}
