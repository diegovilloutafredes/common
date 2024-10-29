//
//  ViewModelable.swift
//

// MARK: - ViewModelable
public protocol ViewModelable: AnyObject {
    associatedtype ViewModelType
}

// MARK: - ViewModelHolder
public protocol ViewModelHolder: ViewModelable {
    var viewModel: ViewModelType? { get set }
}

// MARK: - ViewModelInitializable
public protocol ViewModelInitializable: ViewModelable {
    init(viewModel: ViewModelType)
}

// MARK: - ViewModel
public protocol ViewModel {}


// MARK: - ViewModelSettable
public protocol ViewModelSettable: ViewModelable {
    func set(viewModel: ViewModel)
}

// MARK: - where Self: ViewModelHolder
extension ViewModelSettable where Self: ViewModelHolder {
    public func set(viewModel: ViewModel) {
        self.viewModel = viewModel as? ViewModelType
    }
}
