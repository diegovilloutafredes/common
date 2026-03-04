//
//  Optional+IsNil.swift
//

extension Optional {
    
    /// Checks if the optional is nil.
    public var isNil: Bool {
        switch self {
        case .none: true
        case .some: false
        }
    }
}
