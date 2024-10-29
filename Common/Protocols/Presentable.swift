//
//  Presentable.swift
//

// MARK: - Presentable
public protocol Presentable: AnyObject {
    associatedtype PresenterType
}

public protocol PresenterHolder: Presentable {
    var presenter: PresenterType { get set }
}

public protocol PresenterInitializable: Presentable {
    init(presenter: PresenterType)
}
