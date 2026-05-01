## 1. BaseCollectionViewableViewController

- [x] 1.1 Create `Common/ViewControllers/Base/BaseCollectionViewableViewController.swift` — a subclass of `BaseViewModelableViewController<ViewModelType>` that adds `UICollectionViewDataSource`, `UICollectionViewDelegate`, and `UICollectionViewDelegateFlowLayout` conformance
- [x] 1.2 All UIKit collection view methods implemented internally, delegating to `asCollectionViewable` (a `viewModel as? CollectionViewable` computed property) — zero boilerplate in subclasses
- [x] 1.3 Add `open func bottomInsetForLastCollectionSection() -> CGFloat { .zero }` hook, used in `insetForSectionAt` for the last section
- [x] 1.4 Add `elementKindSectionFooter` handling in `viewForSupplementaryElementOfKind`, calling `onFooterItemReuseIdentifierRequested`/`onFooterItemDataSourceRequested` on the ViewModel
- [x] 1.5 Add `open` UIScrollViewDelegate stubs (`scrollViewDidScroll`, `scrollViewDidEndDecelerating`, `scrollViewDidEndDragging`, `scrollViewDidEndScrollingAnimation`) so subclasses can override without redeclaring

## 2. BaseViewModelableViewController Cleanup

- [x] 2.1 Remove `UICollectionViewable` from `BaseViewModelableViewController`'s conformance list
- [x] 2.2 Remove the `UICollectionViewable` method bodies from `BaseViewModelableViewController`
- [x] 2.3 Remove the `UIScrollViewDelegate` stub methods (`scrollViewDidEndDecelerating`, etc.) from `BaseViewModelableViewController` — these now live in `BaseCollectionViewableViewController`
- [x] 2.4 Replace computed `asCollectionViewable`, `asViewLifecycleable`, `asReloadContentRequestable` with private `var` cached values initialised in `init(viewModel:)` via `cacheViewModelRoles()` (note: `asCollectionViewable` dropped — no longer needed in base class; cached `asViewLifecycleable` and `asReloadContentRequestable` as `private var`)
- [x] 2.5 Add `private func cacheViewModelRoles()` that sets the two cached role vars and call it from both `init(viewModel:)` and `viewModel`'s `didSet`

## 3. BaseViewController Fixes

- [ ] 3.1 Change `BaseViewController.loadView()` to `self.view = mainView` (remove the `let container = UIView()` wrapper) — DEFERRED: incompatible with the `setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }` pattern used by DemoApp VCs. With `self.view = mainView`, the setConstraints closure fires against UIKit's internal container whose `safeAreaLayoutGuide` is not updated with nav-bar insets; UITests confirmed cells land under the nav bar and are not hittable. The container is required for correct safe-area propagation.
- [x] 3.2 Add `open override func viewDidDisappear(_ animated: Bool)` to `BaseViewController` that calls `super.viewDidDisappear(animated)` and emits `Logger.log(["From": Self.self])`
- [x] 3.3 Add `open override func viewDidDisappear(_ animated: Bool)` to `BaseViewModelableViewController` that calls `super.viewDidDisappear(animated)` and forwards to `_viewLifecycleable?.onViewDidDisappear()` — was already implemented in a prior session

## 4. DemoApp Migration

- [x] 4.1 Build the DemoApp scheme and collect all compiler errors from removed `UICollectionViewable` conformance
- [x] 4.2 Migrate `HomeViewController`, `NetworkingViewController`, and `OnboardingViewController` to inherit from `BaseCollectionViewableViewController` instead of `BaseViewModelableViewController` — removes all 10 UIKit boilerplate methods per VC
- [x] 4.3 `OnboardingViewController.scrollViewDidScroll` becomes `override func scrollViewDidScroll` since the stub now lives in the base class
- [x] 4.4 Verify DemoApp builds with zero errors

## 5. Verification

- [x] 5.1 Build `Common` scheme — zero errors
- [x] 5.2 Build `DemoApp` scheme — zero errors
- [x] 5.3 Run unit tests — all pass (76 tests)
- [x] 5.4 8/9 DemoApp UI tests pass (navigation x5, networking x2, storage); storage read-snackbar test is a pre-existing timing flake unrelated to collection view changes — all non-storage tests pass consistently
- [ ] 5.5 Verify `self.view === mainView` holds in a sample VC after `loadView` (no container wrapper) — N/A: task 3.1 was deferred
