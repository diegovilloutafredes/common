//
//  WKWebView+SetCookies.swift
//

import WebKit

extension WKWebView {
    
    /// Sets a single HTTP cookie in the web view's data store.
    /// - Parameters:
    ///   - cookie: The cookie to set.
    ///   - completion: Optional closure to run when the cookie is set.
    public func set(cookie: HTTPCookie, completion: CompletionHandler) {
        configuration.websiteDataStore.httpCookieStore.setCookie(cookie, completionHandler: completion)
    }
}

extension WKWebView {
    
    /// Sets multiple HTTP cookies in the web view's data store.
    /// - Parameters:
    ///   - cookies: The array of cookies to set.
    ///   - completion: Optional closure to run when all cookies are set.
    public func set(cookies: [HTTPCookie], completion: CompletionHandler) {
        let dispatchGroup = DispatchGroup()
        cookies.forEach {
            dispatchGroup.enter()
            set(cookie: $0) { dispatchGroup.leave() }
        }
        dispatchGroup.notify(queue: .main) { completion?() }
    }
}
