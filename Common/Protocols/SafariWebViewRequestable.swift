//
//  SafariWebViewRequestable.swift
//

import SafariServices

// MARK: - SafariWebViewRequestable
public protocol SafariWebViewRequestable: AnyObject {
    func onSafariWebViewRequested(url: URL)
}

// MARK: - Default implementation where Self: BaseCoordinator
extension SafariWebViewRequestable where Self: BaseCoordinator {
    public func onSafariWebViewRequested(url: URL) {
        let vc = SFSafariViewController(url: url)
        navigationController.present(vc, animated: true)
    }
}
