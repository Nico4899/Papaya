//
//  CameraService.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 11.10.25.
//

import Foundation
import AVFoundation

@Observable
class CameraService: NSObject, AVCaptureFileOutputRecordingDelegate {
    let session = AVCaptureSession()
    private let output = AVCaptureMovieFileOutput()
    var onVideoDidFinishSaving: ((URL?, Error?) -> Void)?

    override init() {
        super.init()
        setup()
    }

    private func setup() {
        session.beginConfiguration()
        
        // Attempt to find the camera. This will fail safely on the Simulator.
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("Camera not available (expected if running on Simulator).")
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.commitConfiguration()
    }
    
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }

    func startRecording() {
        guard let connection = output.connection(with: .video), connection.isActive else {
            print("Cannot start recording: No active video connection.")
            return
        }
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        
        output.startRecording(to: tempURL, recordingDelegate: self)
    }

    func stopRecording() {
        if output.isRecording {
            output.stopRecording()
        }
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        onVideoDidFinishSaving?(outputFileURL, error)
    }
}
