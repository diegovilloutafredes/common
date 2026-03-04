//
//  CameraAuthorizationManager.swift
//

import AVFoundation

// MARK: - CameraAuthorizationManager
// MARK: - CameraAuthorizationManager
/// Manages camera access authorization.
public enum CameraAuthorizationManager {
    
    /// The current authorization status for video capture.
    public static var currentStatus: AuthorizationStatus { AVCaptureDevice.authorizationStatus(for: .video).asAuthorizationStatus }

    /// Requests camera access authorization.
    /// - Parameter handler: Completion handler with success status.
    public static func requestAuthorization(handler: @escaping Handler<Bool>) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: handler)
    }
}
