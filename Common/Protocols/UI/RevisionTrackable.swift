//
//  RevisionTrackable.swift
//

// MARK: - RevisionTrackable
/// A view model whose list changes bump a tracked `revision`.
///
/// When the view model of a `BaseCollectionViewableViewController` adopts it, the controller reloads every collection
/// view it is the data source of whenever `revision` differs from the value it last rendered. Keep the items
/// `@ObservationIgnored` and bump an observed `revision` when they change. The controller checks it in its own
/// `updateContent()`, so a subclass that overrides that hook calls `super.updateContent()`, and has no compare of its
/// own.
@MainActor
public protocol RevisionTrackable: AnyObject {

    /// Bumped whenever the items the lists show change.
    var revision: Int { get }
}
