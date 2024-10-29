//
//  WKWebView+SetCookies.swift
//

import WebKit

extension WKWebView {
    public func set(cookie: HTTPCookie, completion: CompletionHandler) {
        configuration.websiteDataStore.httpCookieStore.setCookie(cookie, completionHandler: completion)
    }
}

extension WKWebView {
    public func set(cookies: [HTTPCookie], completion: CompletionHandler) {
        let dispatchGroup = DispatchGroup()
        cookies.forEach {
            dispatchGroup.enter()
            set(cookie: $0) { dispatchGroup.leave() }
        }
        dispatchGroup.notify(queue: .main) { completion?() }
    }
}
