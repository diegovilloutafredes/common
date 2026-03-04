//
//  WKWebView+NavigationDelegate.swift
//

import WebKit

extension WKWebView {
    
    /// Sets the navigation delegate and returns self (chainable).
    /// - Parameter navigationDelegate: The delegate to handle navigation events.
    @discardableResult public func navigationDelegate(_ navigationDelegate: WKNavigationDelegate) -> Self {
        with { $0.navigationDelegate = navigationDelegate }
    }
}
