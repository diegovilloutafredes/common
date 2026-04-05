//
//  SafariWebViewRequestable.swift
//

import SafariServices

// MARK: - SafariWebViewRequestable
// MARK: - SafariWebViewRequestable
/// A protocol for objects that can request to present a `SFSafariViewController`.
public protocol SafariWebViewRequestable: AnyObject {
    
    /// Requests the presentation of a Safari web view for the specified URL.
    /// - Parameter url: The URL to open in Safari.
    func onSafariWebViewRequested(url: URL)
}

// MARK: - Default implementation
extension SafariWebViewRequestable {
    public func onSafariWebViewRequested(url: URL) {
        let vc = SFSafariViewController(url: url)
        dispatchOnMain { UIApplication.shared.topMostViewController?.present(vc, animated: true) }
    }
}
