//
//  TypeAliases.swift
//

import UIKit

// MARK: - Handlers
public typealias Action = () -> Void
public typealias CompletionHandler = Action?
public typealias Handler<T> = (T) -> Void
public typealias InOutHandler<T> = (T) -> (T)
public typealias ResultHandler<T> = Handler<Result<T, Error>>
public typealias CustomErrorResultHandler<T, E: Error> = Handler<Result<T, E>>
public typealias NetworkResultHandler<T> = CustomErrorResultHandler<T, NetworkError>

// MARK: - UIKit related
public typealias ViewControllerHandler = Handler<UIViewController>

public typealias ViewModelableCell = BaseCell & ViewModelHolder & ViewModelSettable
public typealias ViewModelableReusableView = BaseReusableView & ViewModelHolder & ViewModelSettable
public typealias ViewModelableView = BaseView & ViewModelHolder & ViewModelInitializable & ViewModelSettable

public typealias PresentableViewController = BaseViewController & PresenterHolder & PresenterInitializable
public typealias ViewModelableViewController = BaseViewController & ViewModelHolder & ViewModelSettable

public typealias UICollectionViewable = UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout

// MARK: - UIViewsBuilder
public typealias UIViewsBuilder = ArrayBuilder<UIView>


// MARK: - Storable
public typealias Storable = Codable


// MARK: - KeyStorable
public typealias KeyStorable = Keyable & Storable
