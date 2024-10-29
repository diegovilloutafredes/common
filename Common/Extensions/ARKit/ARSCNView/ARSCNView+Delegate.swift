//
//  ARSCNView+Delegate.swift
//

import ARKit

extension ARSCNView {
    @discardableResult public func delegate(_ delegate: (any ARSCNViewDelegate)?) -> Self {
        with { $0.delegate = delegate }
    }
}
