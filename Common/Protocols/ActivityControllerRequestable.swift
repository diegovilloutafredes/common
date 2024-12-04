//
//  ActivityControllerRequestable.swift
//

import UIKit

// MARK: - ActivityControllerRequestable
public protocol ActivityControllerRequestable: AnyObject {
    func onPresentActivityControllerRequested(with item: Any)
}

// MARK: - Default implementation
extension ActivityControllerRequestable {
    public func onPresentActivityControllerRequested(with item: Any) {
        let vc = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        dispatchOnMain { UIApplication.shared.topMostViewController?.present(vc, animated: true) }
    }
}
