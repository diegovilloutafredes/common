//
//  Optional+IsNil.swift
//

extension Optional {
    public var isNil: Bool {
        switch self {
        case .none: true
        case .some: false
        }
    }
}
