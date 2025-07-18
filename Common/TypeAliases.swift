//
//  TypeAliases.swift
//

import UIKit

// MARK: - BaseModuleDelegate
public typealias BaseModuleDelegate = ActivityControllerRequestable & AlertRequestable & DismissRequestable & GoBackRequestable


// MARK: - Handlers
public typealias Action = () -> Void
public typealias CompletionHandler = Action?
public typealias Handler<T> = (T) -> Void
public typealias InOutHandler<T> = (T) -> (T)
public typealias ResultHandler<T> = Handler<Result<T, Error>>
public typealias CustomErrorResultHandler<T, E: Error> = Handler<Result<T, E>>
public typealias NetworkResultHandler<T> = CustomErrorResultHandler<T, NetworkError>
public typealias EmptyResultHandler = Handler<EmptyResult<Error>>
public typealias CustomErrorEmptyResultHandler<E: Error> = Handler<EmptyResult<E>>
public typealias NetworkEmptyResultHandler = CustomErrorEmptyResultHandler<NetworkError>

// MARK: - UIKit related
public typealias CollectionViewable = CollectionViewDataSourceable & CollectionViewDelegateable & CollectionViewSizeable
public typealias ViewModelableCell = BaseCell & OptionalViewModelHolder & ViewModelSettable
public typealias ViewModelableReusableView = BaseReusableView & OptionalViewModelHolder & ViewModelSettable
public typealias ViewModelableView = BaseView & ViewModelHolder & ViewModelInitializable & ViewModelSettable
public typealias ViewModelableViewController = BaseViewController & ViewModelHolder & ViewModelInitializable & ViewModelSettable
public typealias UICollectionViewable = UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout

// MARK: - UIViewsBuilder
public typealias UIViewsBuilder = ArrayBuilder<UIView>


// MARK: - Storable
public typealias Storable = Codable


// MARK: - KeyStorable
public typealias KeyStorable = Keyable & Storable
