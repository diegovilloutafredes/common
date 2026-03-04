//
//  ARSCNView+Delegate.swift
//

import ARKit

extension ARSCNView {
    
    /// Sets the view's delegate and returns self (chainable).
    /// - Parameter delegate: The delegate object.
    @discardableResult
    public func delegate(_ delegate: (any ARSCNViewDelegate)?) -> Self {
        with { $0.delegate = delegate }
    }
}
