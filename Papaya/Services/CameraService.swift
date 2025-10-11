//
//  CameraService.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 11.10.25.
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
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
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

    func startRecording() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = UUID().uuidString + ".mov"
        let fileURL = documentsURL.appendingPathComponent(fileName)
        output.startRecording(to: fileURL, recordingDelegate: self)
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
