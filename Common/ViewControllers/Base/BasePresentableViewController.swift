//
//  BasePresentableViewController.swift
//

import UIKit

// MARK: - BasePresentableViewController
open class BasePresentableViewController<PresenterType>: PresentableViewController, ContentReloadable, UICollectionViewable {
    public var presenter: PresenterType

    private var asCollectionViewable: CollectionViewable? { presenter as? CollectionViewable }
    private var asReloadContentRequestable: ReloadContentRequestable? { presenter as? ReloadContentRequestable }
    private var asViewLifecycleable: ViewLifecycleable? { presenter as? ViewLifecycleable }

    required public init(presenter: PresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    // MARK: - View Lifecycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        asViewLifecycleable?.onViewDidLoad()
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        asViewLifecycleable?.onViewWillLayoutSubviews()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        asViewLifecycleable?.onViewWillAppear()
    }

    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        asViewLifecycleable?.onViewIsAppearing()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        asViewLifecycleable?.onViewDidAppear()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        asViewLifecycleable?.onViewWillDisappear()
    }

    // MARK: - ContentReloadable
    open func reloadContent() {
        Logger.log([.empty: self])
        asReloadContentRequestable?.onReloadContentRequested()
    }

    // MARK: - UICollectionViewable
    open func numberOfSections(in collectionView: UICollectionView) -> Int { asCollectionViewable?.getNumberOfSections() ?? 1 }
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { asCollectionViewable?.getNumberOfItems(in: section) ?? .zero }

    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reuseIdentifier: String { asCollectionViewable?.onHeaderItemReuseIdentifierRequested(in: indexPath.section) ?? .empty }

        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        )

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard
                let viewModelableReusableView = headerView as? any ViewModelableReusableView,
                let viewModel = asCollectionViewable?.onHeaderItemDataSourceRequested(in: indexPath.section)
            else { return headerView }
            viewModelableReusableView.set(viewModel: viewModel)
            return viewModelableReusableView
        default: return headerView
        }
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categoryIndex = indexPath.section
        let reuseIdentifier = asCollectionViewable?.onReuseIdentifierRequested(in: categoryIndex, at: indexPath.item) ?? .empty
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if
            let viewModelSettable = cell as? any ViewModelSettable,
            let viewModel = asCollectionViewable?.onCellForItem(in: categoryIndex, at: indexPath.item)
        { viewModelSettable.set(viewModel: viewModel) }
        return cell
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { asCollectionViewable?.onItemSelected(in: indexPath.section, at: indexPath.item) }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        asCollectionViewable?.onMinimumInteritemSpacingFor(section: section) ?? .zero
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        asCollectionViewable?.onMinimumLineSpacingFor(section: section) ?? .zero
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case (asCollectionViewable?.getNumberOfSections() ?? 1) - 1:
            let bottomInset = closestTabBarHeight + 4
            return .init(top: .zero, left: .zero, bottom: bottomInset, right: .zero)
        default:
            return .zero
        }
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size = asCollectionViewable?.onSizeForHeaderItem(in: section) ?? (.zero, .zero)
        let width = size.width
        let height = size.height
        return .init(width: width, height: height)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = asCollectionViewable?.onSizeForItem(in: indexPath.section, at: indexPath.item) ?? (.zero, .zero)
        let width = size.width
        let height = size.height
        return .init(width: width, height: height)
    }
}
