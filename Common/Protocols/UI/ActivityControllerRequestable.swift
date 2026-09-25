//
//  ActivityControllerRequestable.swift
//

import UIKit

// MARK: - ActivityControllerRequestable
/// A protocol for objects that can request to present a `UIActivityViewController`.
/// - Note: Legacy: in new modules a share sheet is a `ViewEvent` that the view controller presents (guide §6).
@MainActor
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
