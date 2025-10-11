//
//  CameraView.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 11.10.25.
//

import SwiftUI
import AVFoundation

// A UIKit bridge to display the camera preview layer.
struct CameraView: UIViewControllerRepresentable {
    let session: AVCaptureSession

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        // Use a background thread to avoid blocking the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let previewLayer = uiViewController.view.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiViewController.view.bounds
        }
    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: ()) {
        if let previewLayer = uiViewController.view.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            if previewLayer.session?.isRunning == true {
                previewLayer.session?.stopRunning()
            }
        }
    }
}
