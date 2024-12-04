//
//  SafariWebViewRequestable.swift
//

import SafariServices

// MARK: - SafariWebViewRequestable
public protocol SafariWebViewRequestable: AnyObject {
    func onSafariWebViewRequested(url: URL)
}

// MARK: - Default implementation
extension SafariWebViewRequestable {
    public func onSafariWebViewRequested(url: URL) {
        let vc = SFSafariViewController(url: url)
        dispatchOnMain { UIApplication.shared.topMostViewController?.present(vc, animated: true) }
    }
}
