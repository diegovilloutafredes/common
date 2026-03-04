//
//  WKWebView+AllowsContentJavaScript.swift
//

import WebKit

extension WKWebView {
    
    /// Sets whether the web view allows JavaScript content and returns self (chainable).
    /// - Parameter allowsContentJavaScript: `true` to allow JavaScript.
    @discardableResult public func allowsContentJavaScript(_ allowsContentJavaScript: Bool) -> Self {
        with { $0.configuration.defaultWebpagePreferences.allowsContentJavaScript = allowsContentJavaScript }
    }
}
