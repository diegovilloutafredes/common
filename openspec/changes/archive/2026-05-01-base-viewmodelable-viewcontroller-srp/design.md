## Context

`BaseViewModelableViewController<ViewModelType>` currently conforms to `ViewModelableViewController`, `ContentReloadable`, and `UICollectionViewable`. The `UICollectionViewable` conformance means every subclass — whether it shows a list, a form, a camera preview, or a static card — carries 10+ collection view delegate methods as part of its public interface. The methods delegate to `asCollectionViewable` (computed, re-cast every call). The `insetForSectionAt` implementation hard-codes `closestTabBarHeight + 4` for the last section, which is a product decision leaking into the framework. The `viewForSupplementaryElementOfKind` handler silently ignores footer requests.

`BaseViewController.loadView()` creates a throwaway `container = UIView()`, adds `mainView` as its child, and sets `self.view = container`. The `mainView`'s `setConstraints` handler fires via the swizzled `didMoveToSuperview` when it is added to the container, so layout works — but the extra UIView adds a node to every screen hierarchy with no benefit.

## Goals / Non-Goals

**Goals:**
- Remove `UICollectionViewable` from `BaseViewModelableViewController`'s unconditional conformance list
- Provide `CollectionViewSupportable` as an opt-in protocol with the same methods, adoptable by any `BaseViewModelableViewController` subclass
- Cache ViewModel-role casts (`asCollectionViewable`, `asViewLifecycleable`, `asReloadContentRequestable`) at init instead of recomputing per call
- Add an overridable `bottomInsetForLastSection() -> CGFloat` hook replacing the hard-coded tabBar logic
- Handle `elementKindSectionFooter` in `viewForSupplementaryElementOfKind`
- Add `viewDidDisappear` override to `BaseViewController`
- Eliminate the container `UIView` in `BaseViewController.loadView()`

**Non-Goals:**
- Changing the public ViewModel protocol hierarchy (`ViewModelable`, `ViewModelHolder`, etc.)
- Migrating to `UICollectionViewDiffableDataSource` or compositional layout
- Altering DemoApp module logic beyond adoption of `CollectionViewSupportable`

## Decisions

### D1: CollectionViewSupportable as a protocol extension, not a subclass

**Decision:** Introduce `CollectionViewSupportable` as a protocol whose default implementations are provided via extensions on `BaseViewModelableViewController`. Adopting VCs declare `extension MyVC: CollectionViewSupportable {}` — no subclassing.

**Rationale:** Subclassing would create a parallel hierarchy (`BaseCollectionViewController` vs `BaseViewModelableViewController`) that consumers must choose between. A protocol that piggybacks on the existing VC type avoids the choice: a VC is always a `BaseViewModelableViewController`; it optionally conforms to `CollectionViewSupportable`. UIKit wires delegate/datasource at the call site, not via type hierarchy.

**Alternative considered:** Make `BaseViewModelableViewController` abstract and split into `BaseFormViewController` / `BaseListViewController`. Too invasive; breaks all existing subclasses.

### D2: Cache casts as `let` constants at init

**Decision:** Replace `private var asCollectionViewable: CollectionViewable? { viewModel as? CollectionViewable }` computed properties with `private let _collectionViewable: CollectionViewable?` stored at `init(viewModel:)`.

**Rationale:** The ViewModel type is fixed at construction. Re-casting on every `numberOfItemsInSection`, `cellForItemAt`, etc. is wasted work. `let` constants are cheaper and communicate intent.

**Constraint:** Must be set before `super.init` is called — Swift requires all stored properties to be initialised before `super.init`. Use `let` with `= viewModel as? CollectionViewable` in the initialiser body after assigning `self.viewModel`.

### D3: Bottom inset hook

**Decision:** Add `open func bottomInsetForLastCollectionSection() -> CGFloat { .zero }` to `CollectionViewSupportable`'s default implementation of `insetForSectionAt`.

**Rationale:** Returning `.zero` as the default removes the tab-bar coupling from the framework. Consumer VCs that need the tab-bar offset override the hook: `override func bottomInsetForLastCollectionSection() -> CGFloat { closestTabBarHeight + 4 }`. This is the correct inversion of control.

### D4: loadView — direct assignment

**Decision:** Replace `let container = UIView(); container.addSubview(mainView); self.view = container` with `self.view = mainView`.

**Rationale:** `mainView` becomes the root view directly. UIKit sets it to fill the screen. Any `setConstraints` handler that the mainView registered still fires (it fires on `didMoveToSuperview`, which happens when UIKit installs the root view). This removes one UIView node from every screen.

**Risk:** Any consumer code that does `view.subviews.first` to reach `mainView` will break. Audit DemoApp and document.

### D5: viewDidDisappear in BaseViewController

**Decision:** Add `open override func viewDidDisappear(_ animated: Bool)` to `BaseViewController` that calls `super` and forwards to `asViewLifecycleable?.onViewDidDisappear()` — but since `BaseViewController` does not have access to the ViewModel, this forwarding belongs in `BaseViewModelableViewController`. `BaseViewController` only needs to add `super.viewDidDisappear(animated)` and a Logger call.

**Rationale:** `BaseViewModelableViewController` already overrides all other lifecycle methods. Adding `viewDidDisappear` there (alongside `viewWillDisappear`) is consistent.

## Risks / Trade-offs

- **BREAKING: removing UICollectionViewable** → Any consumer VC that relied on the inherited collection view method stubs (returning `.zero`, `1`, empty cell) without explicit declarations will lose those defaults. Fix: adopt `CollectionViewSupportable`. All DemoApp screens that use lists will need explicit adoption. Document clearly in changelog.
- **`self.view = mainView` removes container UIView** → Consumer code doing `self.view.subviews.first` to access the main content view will get a different result. Audit DemoApp before shipping.
- **Cached casts become stale if ViewModel is replaced** → `BaseViewModelableViewController.viewModel` is `open var`, so a consumer can replace it after init. The cached casts (`_collectionViewable` etc.) will point to the old ViewModel. Mitigation: make `viewModel` trigger a re-cache in `didSet`. Document.

## Migration Plan

1. Implement `CollectionViewSupportable` protocol with default implementations
2. Update `BaseViewModelableViewController` to remove `UICollectionViewable`, add caching, add inset hook, fix footer
3. Update `BaseViewController` (loadView, viewDidDisappear)
4. Build framework — expected: errors in DemoApp where collection view methods are inherited
5. Update each DemoApp screen to adopt `CollectionViewSupportable` explicitly
6. Run tests; confirm DemoApp builds and behaves identically

## Open Questions

- Should `CollectionViewSupportable` be in a separate file or in `BaseViewModelableViewController.swift`? (Recommendation: separate file `ViewControllers/Protocols/CollectionViewSupportable.swift` for discoverability.)
- Should `viewModel`'s `didSet` re-cache the casts? (Recommendation: yes, to be safe; add a private `cacheViewModelRoles()` method called from init and didSet.)
