//
//  BaseCollectionViewableViewController.swift
//

import UIKit

// MARK: - BaseCollectionViewableViewController

/// A base view controller for modules whose ViewModel conforms to `CollectionViewable`.
///
/// Subclass this instead of `BaseViewModelableViewController` when the screen owns
/// a `VList` or `HList`. All `UICollectionViewDataSource`, `UICollectionViewDelegate`,
/// and `UICollectionViewDelegateFlowLayout` methods are implemented here and delegate
/// directly to `viewModel` — no boilerplate required in the subclass.
///
/// Override `bottomInsetForLastCollectionSection()` in subclasses that sit above a
/// visible tab bar.
open class BaseCollectionViewableViewController<ViewModelType>: BaseViewModelableViewController<ViewModelType>,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout {

    private var asCollectionViewable: CollectionViewable? { viewModel as? CollectionViewable }

    open func bottomInsetForLastCollectionSection() -> CGFloat { .zero }

    // MARK: - UICollectionViewDataSource

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        asCollectionViewable?.getNumberOfSections() ?? 1
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        asCollectionViewable?.getNumberOfItems(in: section) ?? .zero
    }

    open func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let reuseIdentifier: String
        let dataSourceViewModel: ViewModel?

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            reuseIdentifier = asCollectionViewable?.onHeaderItemReuseIdentifierRequested(in: indexPath.section) ?? .empty
            dataSourceViewModel = asCollectionViewable?.onHeaderItemDataSourceRequested(in: indexPath.section)
        case UICollectionView.elementKindSectionFooter:
            reuseIdentifier = asCollectionViewable?.onFooterItemReuseIdentifierRequested(in: indexPath.section) ?? .empty
            dataSourceViewModel = asCollectionViewable?.onFooterItemDataSourceRequested(in: indexPath.section)
        default:
            reuseIdentifier = .empty
            dataSourceViewModel = nil
        }

        let supplementaryView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath
        )

        guard
            let viewModelableView = supplementaryView as? any ViewModelableReusableView,
            let dataSourceViewModel
        else { return supplementaryView }

        viewModelableView.set(viewModel: dataSourceViewModel)
        return supplementaryView
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = asCollectionViewable?.onReuseIdentifierRequested(in: indexPath.section, at: indexPath.item) ?? .empty
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        guard
            let viewModelableCell = cell as? any ViewModelableCell,
            let cellViewModel = asCollectionViewable?.onCellForItem(in: indexPath.section, at: indexPath.item)
        else { return cell }
        viewModelableCell.set(viewModel: cellViewModel)
        return viewModelableCell
    }

    // MARK: - UICollectionViewDelegate

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        asCollectionViewable?.onItemSelected(in: indexPath.section, at: indexPath.item)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    open func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        asCollectionViewable?.onMinimumInteritemSpacingFor(section: section) ?? .zero
    }

    open func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        asCollectionViewable?.onMinimumLineSpacingFor(section: section) ?? .zero
    }

    open func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let base = asCollectionViewable?.onInsetFor(section: section) ?? (.zero, .zero, .zero, .zero)
        let isLastSection = section == (asCollectionViewable?.getNumberOfSections() ?? 1) - 1
        let extraBottom = isLastSection ? bottomInsetForLastCollectionSection() : .zero
        return .init(top: base.top, left: base.left, bottom: base.bottom + extraBottom, right: base.right)
    }

    open func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let size = asCollectionViewable?.onSizeForHeaderItem(in: section) ?? (.zero, .zero)
        return .init(width: size.width, height: size.height)
    }

    open func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let size = asCollectionViewable?.onSizeForItem(in: indexPath.section, at: indexPath.item) ?? (.zero, .zero)
        return .init(width: size.width, height: size.height)
    }

    // MARK: - UIScrollViewDelegate stubs

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {}
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {}
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {}
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {}
}
