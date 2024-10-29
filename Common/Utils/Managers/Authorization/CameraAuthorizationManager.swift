//
//  CameraAuthorizationManager.swift
//

import AVFoundation

// MARK: - CameraAuthorizationManager
public enum CameraAuthorizationManager {
    public static var currentStatus: AuthorizationStatus { AVCaptureDevice.authorizationStatus(for: .video).asAuthorizationStatus }

    public static func requestAuthorization(handler: @escaping Handler<Bool>) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: handler)
    }
}
