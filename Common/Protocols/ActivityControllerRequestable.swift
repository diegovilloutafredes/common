//
//  ActivityControllerRequestable.swift
//

import UIKit

// MARK: - ActivityControllerRequestable
public protocol ActivityControllerRequestable: AnyObject {
    func onPresentActivityControllerRequested(with url: URL)
}

// MARK: - Default implementation
extension ActivityControllerRequestable {
    public func onPresentActivityControllerRequested(with url: URL) {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        dispatchOnMain {
            UIApplication.shared.topMostViewController?.present(vc, animated: true)
        }
    }
}
