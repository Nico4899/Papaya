//
//  PermissionManager.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 10.10.25.
//

import AVFoundation

struct PermissionManager {
    static func requestCameraAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }
}
