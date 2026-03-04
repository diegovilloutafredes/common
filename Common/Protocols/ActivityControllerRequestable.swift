//
//  ActivityControllerRequestable.swift
//

import UIKit

// MARK: - ActivityControllerRequestable
// MARK: - ActivityControllerRequestable
/// A protocol for objects that can request to present a `UIActivityViewController`.
public protocol ActivityControllerRequestable: AnyObject {
    
    /// Requests the presentation of an activity controller with a specific item.
    /// - Parameter item: The item to share or act upon.
    func onPresentActivityControllerRequested(with item: Any)
}

// MARK: - Default implementation
extension ActivityControllerRequestable {
    public func onPresentActivityControllerRequested(with item: Any) {
        let vc = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        dispatchOnMain { UIApplication.shared.topMostViewController?.present(vc, animated: true) }
    }
}
