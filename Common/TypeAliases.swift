//
//  TypeAliases.swift
//

import UIKit

// MARK: - BaseModuleDelegate
// MARK: - BaseModuleDelegate

/// A composition of protocols defining the base delegate requirements for a module.
/// Includes capabilities for requesting activity controllers, alerts, dismissals, and navigation back.
public typealias BaseModuleDelegate = ActivityControllerRequestable & AlertRequestable & DismissRequestable & GoBackRequestable


// MARK: - Handlers

/// A simple closure that takes no arguments and returns no value.
public typealias Action = () -> Void

/// An optional `Action` closure, often used for completion callbacks.
public typealias CompletionHandler = Action?

/// A generic closure that takes a value of type `T` and returns no value.
public typealias Handler<T> = (T) -> Void

/// A generic closure that takes a value of type `T` and returns a value of type `T`.
public typealias InOutHandler<T> = (T) -> (T)

/// A handler for `Result` types containing a value of type `T` or an `Error`.
public typealias ResultHandler<T> = Handler<Result<T, Error>>

/// A handler for `Result` types containing a value of type `T` or a specific error type `E`.
public typealias CustomErrorResultHandler<T, E: Error> = Handler<Result<T, E>>

/// A `ResultHandler` specialized for `NetworkError`.
public typealias NetworkResultHandler<T> = CustomErrorResultHandler<T, NetworkError>

/// A handler for `EmptyResult` with a generic `Error`.
public typealias EmptyResultHandler = Handler<EmptyResult<Error>>

/// A handler for `EmptyResult` with a specific error type `E`.
public typealias CustomErrorEmptyResultHandler<E: Error> = Handler<EmptyResult<E>>

/// An `EmptyResultHandler` specialized for `NetworkError`.
public typealias NetworkEmptyResultHandler = CustomErrorEmptyResultHandler<NetworkError>

// MARK: - UIKit related

/// A composition of protocols for objects that can serve as a collection view's data source, delegate, and size delegate.
public typealias CollectionViewable = CollectionViewDataSourceable & CollectionViewDelegateable & CollectionViewSizeable

/// A composition of protocols for cells that are view model driven.
public typealias ViewModelableCell = BaseCell & OptionalViewModelHolder & ViewModelSettable

/// A composition of protocols for reusable views that are view model driven.
public typealias ViewModelableReusableView = BaseReusableView & OptionalViewModelHolder & ViewModelSettable

/// A composition of protocols for views that are view model driven and initializable.
public typealias ViewModelableView = BaseView & ViewModelHolder & ViewModelInitializable & ViewModelSettable

/// A composition of protocols for view controllers that are view model driven and initializable.
public typealias ViewModelableViewController = BaseViewController & ViewModelHolder & ViewModelInitializable & ViewModelSettable

/// A composition of standard UIKit collection view protocols.
public typealias UICollectionViewable = UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout

// MARK: - UIViewsBuilder

/// A result builder for creating arrays of `UIView`.
public typealias UIViewsBuilder = ArrayBuilder<UIView>


// MARK: - Storage

/// A type alias for `Codable` objects that can be stored.
public typealias Storable = Codable

/// A composition of `Keyable` and `Storable` protocols.
public typealias KeyStorable = Keyable & Storable

/// A composition of protocols for storage that supports single object storage with raw value keys.
public typealias SingleRawValueKeyValueObjectStorage = RawValueKeyValueStore & SingleObjectStorage
