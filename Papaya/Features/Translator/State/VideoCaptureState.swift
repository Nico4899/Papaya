//
//  VideoCaptureState.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 11.10.25.
//

import Foundation
import AVFoundation

@Observable
final class VideoCaptureState {
    var cameraService = CameraService()
    
    var countdown = 3
    var countdownTimer: Timer?
    
    var showCamera = false
    var capturePhase: CapturePhase = .idle
    var recordedVideoURL: URL?
    
    enum CapturePhase {
        case idle, countingDown, recording, review
    }
    
    func startCountdown() {
        capturePhase = .countingDown
        countdown = 3
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tickCountdown()
        }
    }
    
    private func tickCountdown() {
        if countdown > 1 {
            countdown -= 1
        } else {
            countdownTimer?.invalidate()
            countdownTimer = nil
            startRecording()
        }
    }
    
    private func startRecording() {
        capturePhase = .recording
        cameraService.startRecording()
    }
    
    func stopRecording() {
        cameraService.onVideoDidFinishSaving = { [weak self] url, error in
            DispatchQueue.main.async {
                if let url = url, error == nil {
                    self?.recordedVideoURL = url
                    self?.capturePhase = .review
                } else {
                    print("Error saving video: \(error?.localizedDescription ?? "Unknown error")")
                    self?.reset()
                }
            }
        }
        cameraService.stopRecording()
    }
    
    func retake() {
        recordedVideoURL = nil
        capturePhase = .idle
    }
    
    func reset() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        recordedVideoURL = nil
        capturePhase = .idle
    }
}
