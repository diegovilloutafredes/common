//
//  WKWebView+AllowsContentJavaScript.swift
//

import WebKit

extension WKWebView {
    @discardableResult public func allowsContentJavaScript(_ allowsContentJavaScript: Bool) -> Self {
        with { $0.configuration.defaultWebpagePreferences.allowsContentJavaScript = allowsContentJavaScript }
    }
}
