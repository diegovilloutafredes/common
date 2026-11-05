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

    /// Cached once per `viewModel` assignment — delegate and sizing methods run
    /// several times per scroll frame, so the conformance cast must not be repeated there.
    private var asCollectionViewable: CollectionViewable?
    /// Cached the same way: read on every update pass.
    private var asRevisionTrackable: RevisionTrackable?
    /// The collection views this controller is the data source of, recorded as they ask it for their counts, each with
    /// the revision its data was loaded at. Weak keys: a list that goes away drops out.
    private let servedCollectionViews = NSMapTable<UICollectionView, LoadedRevision>.weakToStrongObjects()

    open override var viewModel: ViewModelType {
        didSet {
            asCollectionViewable = viewModel as? CollectionViewable
            asRevisionTrackable = viewModel as? RevisionTrackable
            // Every served list reloads from the new model, whatever it conforms to. Forgetting them first keeps the
            // pass this assignment schedules from reloading them a second time: each list registers again, at the new
            // model's revision, as it reloads. Reading no revision here keeps an assignment made inside another
            // controller's hook out of that hook's tracking.
            let lists = servedLists
            servedCollectionViews.removeAllObjects()
            lists.forEach { $0.reloadData() }
            if lists.isNotEmpty { listsDidReload() }
        }
    }

    required public init(viewModel: ViewModelType) {
        super.init(viewModel: viewModel)
        asCollectionViewable = viewModel as? CollectionViewable
        asRevisionTrackable = viewModel as? RevisionTrackable
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    open func bottomInsetForLastCollectionSection() -> CGFloat { .zero }

    /// Reloads each list this controller serves whose data was loaded at a revision other than the current one of a
    /// `RevisionTrackable` view model, then calls `listsDidReload()` once if it reloaded any. A list that loads during
    /// the first pass is current and isn't reloaded; one that loaded earlier, at an older revision, is. Subclasses that
    /// override this hook call `super.updateContent()`.
    open override func updateContent() {
        super.updateContent()
        guard let revision = asRevisionTrackable?.revision else { return }
        let behind = servedLists.filter { servedCollectionViews.object(forKey: $0)?.value != revision }
        behind.forEach {
            servedCollectionViews.setObject(.init(revision), forKey: $0)
            $0.reloadData()
        }
        if behind.isNotEmpty { listsDidReload() }
    }

    /// Called once after the controller reloads its lists: at the end of an update pass in which a `RevisionTrackable`
    /// view model's revision moved and one or more lists reloaded, and right after replacing the view model reloads the
    /// lists the controller serves. Not called when nothing reloaded. Empty by default.
    ///
    /// Override it to refresh what depends on the rows, such as a count or a badge, by scheduling that work here:
    ///
    /// ```swift
    /// override func listsDidReload() {
    ///     super.listsDidReload()
    ///     badge.setNeedsContentUpdate()
    /// }
    /// ```
    ///
    /// `reloadData()` only asks a list to reload, and its rows load on the list's next layout, so don't read them here.
    /// After a revision move it runs inside the update pass, from `super.updateContent()`: in a subclass that calls
    /// `super` first it runs before the rest of its hook, and on iOS 17–18 what it reads is tracked like the hook's reads.
    open func listsDidReload() {}

    private var servedLists: [UICollectionView] {
        servedCollectionViews.keyEnumerator().allObjects.compactMap { $0 as? UICollectionView }
    }

    /// Records that `collectionView` loaded its counts from the current view model, at its current revision. Both count
    /// callbacks record it, so a subclass that overrides one of them without `super` still has its list served.
    private func recordDataLoad(by collectionView: UICollectionView) {
        let revision = asRevisionTrackable?.revision
        if let loaded = servedCollectionViews.object(forKey: collectionView), loaded.value == revision { return }
        servedCollectionViews.setObject(.init(revision), forKey: collectionView)
    }

    // MARK: - UICollectionViewDataSource

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        recordDataLoad(by: collectionView)
        return asCollectionViewable?.getNumberOfSections() ?? 1
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        recordDataLoad(by: collectionView)
        return asCollectionViewable?.getNumberOfItems(in: section) ?? .zero
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

        guard let viewModelableView = supplementaryView as? any ViewModelableReusableView else { return supplementaryView }
        bind(dataSourceViewModel, to: viewModelableView)
        return supplementaryView
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = asCollectionViewable?.onReuseIdentifierRequested(in: indexPath.section, at: indexPath.item) ?? .empty
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        guard let viewModelableCell = cell as? any ViewModelableCell else { return cell }
        bind(asCollectionViewable?.onCellForItem(in: indexPath.section, at: indexPath.item), to: viewModelableCell)
        return viewModelableCell
    }

    /// Assigns the data source's model to a dequeued view, nil included, so a recycled view never keeps the model of
    /// the item it showed before. The view's `updateContent()` then renders the nil state.
    private func bind<View: OptionalViewModelHolder & ViewModelSettable>(_ viewModel: ViewModel?, to view: View) {
        if let viewModel { view.set(viewModel: viewModel) } else { view.viewModel = nil }
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
        let available = availableSize(in: collectionView, layout: collectionViewLayout, section: section)
        let size = asCollectionViewable?.onSizeForHeaderItem(in: section, availableSize: available) ?? (.zero, .zero)
        return .init(width: size.width, height: size.height)
    }

    open func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        let available = availableSize(in: collectionView, layout: collectionViewLayout, section: section)
        let size = asCollectionViewable?.onSizeForFooterItem(in: section, availableSize: available) ?? (.zero, .zero)
        return .init(width: size.width, height: size.height)
    }

    open func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let available = availableSize(in: collectionView, layout: collectionViewLayout, section: indexPath.section)
        let size = asCollectionViewable?.onSizeForItem(in: indexPath.section, at: indexPath.item, availableSize: available) ?? (.zero, .zero)
        return .init(width: size.width, height: size.height)
    }

    /// The size an item, header or footer in `section` may occupy: the bounds inset by the adjusted content inset
    /// and by the section inset this controller reports, clamped at zero. Computed inside the
    /// sizing callback, where the collection view is already laid out.
    private func availableSize(in collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> Size {
        let sectionInset = self.collectionView(collectionView, layout: layout, insetForSectionAt: section)
        let contentInset = collectionView.adjustedContentInset
        // Plain subtraction: `CGRect.inset(by:)` standardizes an over-inset rect into a positive size.
        let width = collectionView.bounds.width - contentInset.left - contentInset.right - sectionInset.left - sectionInset.right
        let height = collectionView.bounds.height - contentInset.top - contentInset.bottom - sectionInset.top - sectionInset.bottom
        return (max(width, .zero), max(height, .zero))
    }

    // MARK: - UIScrollViewDelegate stubs
    //
    // Scroll-delegate methods introduced directly in a subclass of this generic class
    // are invisible to ObjC selector dispatch and are silently never called. Any scroll
    // callback a subclass needs must exist here as an open stub to override.

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {}
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {}
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {}
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {}
    open func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {}
}

// MARK: - LoadedRevision

/// The revision a served list's data was loaded at, `nil` when the view model doesn't track revisions.
private final class LoadedRevision {
    let value: Int?

    init(_ value: Int?) { self.value = value }
}
