## ADDED Requirements

### Requirement: CollectionViewSupportable is an opt-in protocol
The system SHALL provide a `CollectionViewSupportable` protocol that `BaseViewModelableViewController` subclasses can adopt when they use a `UICollectionView`, replacing the previously unconditional `UICollectionViewable` conformance.

#### Scenario: VC without collection view has no collection view methods
- **WHEN** a `BaseViewModelableViewController` subclass does NOT conform to `CollectionViewSupportable`
- **THEN** the VC's public interface contains no `UICollectionViewDataSource`, `UICollectionViewDelegate`, or `UICollectionViewDelegateFlowLayout` methods

#### Scenario: VC with collection view adopts CollectionViewSupportable
- **WHEN** a `BaseViewModelableViewController` subclass declares conformance to `CollectionViewSupportable`
- **THEN** all `UICollectionViewable` method implementations are available via protocol default implementations, with the same delegation-to-ViewModel behaviour as before

#### Scenario: CollectionViewSupportable compiles without additional boilerplate
- **WHEN** a VC writes `extension MyVC: CollectionViewSupportable {}`
- **THEN** the file compiles with no required method implementations (defaults cover all required methods)

### Requirement: Bottom inset is configurable per VC
The `CollectionViewSupportable` default implementation of `insetForSectionAt` SHALL call an overridable `bottomInsetForLastCollectionSection() -> CGFloat` hook instead of hard-coding `closestTabBarHeight + 4`.

#### Scenario: Default inset is zero
- **WHEN** a VC adopts `CollectionViewSupportable` and does not override `bottomInsetForLastCollectionSection()`
- **THEN** `collectionView(_:layout:insetForSectionAt:)` returns `.zero` for the bottom edge of the last section

#### Scenario: Consumer overrides the inset hook
- **WHEN** a VC overrides `bottomInsetForLastCollectionSection()` to return `closestTabBarHeight + 4`
- **THEN** `collectionView(_:layout:insetForSectionAt:)` returns that value for the last section's bottom edge

### Requirement: Footer supplementary views are handled
The `CollectionViewSupportable` implementation of `viewForSupplementaryElementOfKind` SHALL handle both `elementKindSectionHeader` and `elementKindSectionFooter` kinds.

#### Scenario: Footer kind is requested
- **WHEN** `collectionView(_:viewForSupplementaryElementOfKind:at:)` is called with `UICollectionView.elementKindSectionFooter`
- **THEN** the method dequeues and configures the footer view using `onFooterItemReuseIdentifierRequested` and `onFooterItemDataSourceRequested` from the ViewModel

### Requirement: ViewModel collection roles are cached at init
The `CollectionViewSupportable` conformance SHALL cache the ViewModel's `CollectionViewable` role at VC initialisation time, not recompute it on every delegate call.

#### Scenario: Cast does not repeat on each delegate method
- **WHEN** `numberOfItemsInSection`, `cellForItemAt`, and `didSelectItemAt` are each called once
- **THEN** the conditional cast `viewModel as? CollectionViewable` executes exactly once total (at init), not three times

## REMOVED Requirements

### Requirement: Unconditional UICollectionViewable on every VC
**Reason**: SRP violation — screens without collection views carry unused delegate surface area, and domain-specific inset logic was embedded in the framework base class.
**Migration**: Adopt `CollectionViewSupportable` on any `BaseViewModelableViewController` subclass that sets a `UICollectionView`'s dataSource or delegate to `self`. Override `bottomInsetForLastCollectionSection()` to restore tab-bar inset behaviour.
