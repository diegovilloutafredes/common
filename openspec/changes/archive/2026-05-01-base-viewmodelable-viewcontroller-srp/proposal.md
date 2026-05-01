## Why

`BaseViewModelableViewController` violates the Single Responsibility Principle by unconditionally conforming every view controller to `UICollectionViewable` (data source + delegate + flow layout), regardless of whether the screen uses a collection view. This bloats every VC's API surface, injects tab-bar inset domain logic into the framework base class, and makes the ViewModel cast repeated on every delegate call. `BaseViewController.loadView()` also wraps `mainView` in an unnecessary container `UIView`, adding a spurious node to every screen's hierarchy.

## What Changes

- **BREAKING** Remove unconditional `UICollectionViewable` conformance from `BaseViewModelableViewController`; replace with an opt-in `CollectionViewSupportable` protocol that VCs can adopt when they actually use a collection view
- Extract tab-bar bottom inset logic out of `insetForSectionAt` into an overridable hook so consumer apps supply domain-specific values
- Cache `asCollectionViewable`, `asViewLifecycleable`, and `asReloadContentRequestable` casts at init time instead of recomputing on every delegate call
- Add `viewForSupplementaryElementOfKind` handling for `elementKindSectionFooter` (currently silently ignored)
- Add `viewDidDisappear` override to `BaseViewController` so `ViewLifecycleable.onViewDidDisappear()` is forwarded from the base class
- Remove the intermediate container `UIView` in `BaseViewController.loadView()`; set `self.view = mainView` directly

## Capabilities

### New Capabilities

- `collection-view-supportable`: Opt-in protocol for VCs that need collection view data source/delegate/flow-layout wiring, decoupled from the base VC hierarchy
- `viewcontroller-lifecycle-completeness`: `BaseViewController` forwards all `UIViewController` lifecycle events including `viewDidDisappear`; `BaseViewModelableViewController` caches ViewModel casts at init

### Modified Capabilities

<!-- No existing openspec specs to delta — this is a new project-level spec introduction -->

## Impact

- **`ViewControllers/Base/BaseViewModelableViewController.swift`** — removes `UICollectionViewable` conformance, caches casts, fixes footer, exposes inset hook
- **`ViewControllers/Base/BaseViewController.swift`** — adds `viewDidDisappear`, removes container UIView
- **Consumer VCs that relied on implicit `UICollectionViewable`** — must now explicitly adopt `CollectionViewSupportable` (**BREAKING** for any subclass that used the inherited collection view methods without re-declaring them)
- **DemoApp** — all collection-view-using screens must be updated to adopt `CollectionViewSupportable`
- No networking, storage, or extension changes
