//
//  WKWebView+NavigationDelegate.swift
//

import WebKit

extension WKWebView {
    @discardableResult public func navigationDelegate(_ navigationDelegate: WKNavigationDelegate) -> Self {
        with { $0.navigationDelegate = navigationDelegate }
    }
}
