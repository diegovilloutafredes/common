//
//  ViewModelable.swift
//

// MARK: - ViewModelable
// MARK: - ViewModelable
/// A base protocol for objects that are associated with a view model.
public protocol ViewModelable: AnyObject {
    /// The type of view model associated with the object.
    associatedtype ViewModelType
}

// MARK: - OptionalViewModelHolder
/// A protocol for objects that hold an optional view model.
public protocol OptionalViewModelHolder: ViewModelable {
    /// The optional view model instance.
    var viewModel: ViewModelType? { get set }
}

/// A protocol for objects that hold a non-optional view model.
public protocol ViewModelHolder: ViewModelable {
    /// The view model instance.
    var viewModel: ViewModelType { get set }
}

// MARK: - ViewModelInitializable
/// A protocol for objects that can be initialized with a view model.
public protocol ViewModelInitializable: ViewModelable {
    /// Initializes a new instance with the specified view model.
    /// - Parameter viewModel: The view model to use.
    init(viewModel: ViewModelType)
}

// MARK: - ViewModel
/// A marker protocol for all view models.
public protocol ViewModel {}


// MARK: - ViewModelSettable
/// A protocol for objects whose view model can be set generically.
public protocol ViewModelSettable: ViewModelable {
    /// Sets the view model of the object.
    /// - Parameter viewModel: The view model instance.
    func set(viewModel: ViewModel)
}

// MARK: - where Self: OptionalViewModelHolder
extension ViewModelSettable where Self: OptionalViewModelHolder {
    public func set(viewModel: ViewModel) {
        self.viewModel = viewModel as? ViewModelType
    }
}

// MARK: - where Self: ViewModelHolder
extension ViewModelSettable where Self: ViewModelHolder {
    public func set(viewModel: ViewModel) {
        self.viewModel = viewModel as! ViewModelType
    }
}
