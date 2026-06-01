# DemoApp — Framework Compliance Review

Analyzed against `.claude/skills/common-framework.md` (the distilled skill derived from `COMMON_FRAMEWORK_GUIDE.md`).

**Scope:** 14 modules, 55 Swift files  
**Date:** 2026-05-11

---

## Summary

| Category | Count |
|---|---|
| Critical violations | 2 files |
| Pattern violations | 4 modules |
| Missing demonstrations | 8 framework features |
| Small gaps | 4 |
| Reference-quality modules | 6 |

---

## Critical Violations

### 1. `Modules/Main/ViewController.swift` — prototype left in production

Every rule it violates is a rule new developers will copy, making this the highest-priority fix.

| Violation | Rule |
|---|---|
| `setupView()` does not call `super.setupView()` | Always call `super.setupView()` first |
| `present(vc, animated: true)` called directly from the VC | Never navigate directly from a ViewController — route through coordinator |
| `dispatchOnMain { dispatchOnMain { ... } }` nested double-dispatch | Use `Task { @MainActor in }` not `dispatchOnMain` |
| `User`, `Info`, `UserStorage`, `UserLocalStorageUseCase` defined in the VC file | Model and UseCase types belong in their own files |

**Recommended action:** Delete the file entirely. `UserLocalStorageUseCase` is the only thing worth keeping — move it to `Storage/` as a proper example.

---

### 2. `Modules/CoordinatorDemo/ChildFlowViewController.swift` — wrong base class

| Violation | Rule |
|---|---|
| Extends `UIViewController` directly | Never use `UIViewController` — always `BaseViewController` or subclass |
| Overrides `viewDidLoad()` directly | Use `setupView()` hook |
| Overrides `viewWillAppear()` directly | Use `onViewWillAppear { }` hook in `setupView()` |
| `view.addSubview(container)` + `NSLayoutConstraint.activate` + `translatesAutoresizingMaskIntoConstraints = false` | Use `setConstraints { }` — it handles `translatesAutoresizingMaskIntoConstraints` automatically |

**Note:** The `viewWillDisappear + isMovingFromParent` pattern is intentional and documented — keep it.  
**Recommended action:** Rebase on `BaseViewController`. Move `buildUI()` content into `mainView`. Replace lifecycle overrides with hooks. This preserves the coordinator demo intent while teaching the correct base class.

---

## Pattern Violations

### 3. `Modules/CoordinatorDemo/CoordinatorDemoViewController.swift`

| Violation | Rule |
|---|---|
| `override func viewWillAppear()` called directly | Use `onViewWillAppear { }` hook in `setupView()` |
| `buildScrollContent()` uses `NSLayoutConstraint.activate` | Use `setConstraints { }` (the UIScrollView exception allows direct constraints but other modules do it correctly via the DSL — inconsistency) |
| `mainScrollView` uses closure-based `= { let sv = UIScrollView(); ... }()` | Use fluent chain: `UIScrollView().with { $0.alwaysBounceVertical = true }` |

---

### 4. `Modules/CoordinatorDemo/CoordinatorDemoCoordinator.swift` — no Wireframe

`start()` creates the VC and VM directly, bypassing the Wireframe factory pattern. This was done so the coordinator can hold `weak var viewModel` for later stats updates, but it contradicts what the DemoApp is supposed to teach.

**Recommended action:** Consider a `CoordinatorDemoWireframe` that returns both the VC and a `CoordinatorDemoViewModelProtocol` reference, or document the intentional deviation with an inline comment.

---

### 5. `Modules/Home/HomeWireframe.swift` + `HomeViewModel.swift` — missing coordinator protocol isolation

| File | Violation |
|---|---|
| `HomeWireframe` | `createModule(coordinator: AppCoordinator)` — takes a concrete class, not a protocol |
| `HomeViewModel` | `weak var coordinator: AppCoordinator?` — holds the concrete coordinator type |

Every other module that navigates through a coordinator (`Alerts`, `Onboarding`) correctly defines a protocol. Home is the entry point and the most prominent example — it should be the best, not the outlier.

**Fix:**
```swift
protocol HomeCoordinatorProtocol: AnyObject {
    func showDeclarativeUI()
    func showNetworking()
    // ... etc.
}
extension AppCoordinator: HomeCoordinatorProtocol {}
```

---

### 6. `Modules/Onboarding/OnboardingViewController.swift` — `OnboardingStep` name collision

The file defines an inner `enum OnboardingStep` (with `var buttonTitle`) that shadows the top-level `OnboardingStep` in `OnboardingStep.swift` (which conforms to `OnboardingCellViewModel`). Swift resolves these without a compile error, but reading the code is ambiguous and confusing.

**Fix:** Rename the inner enum to `OnboardingPage` or `OnboardingButtonState`.

---

## Missing Demonstrations

These framework capabilities exist and are documented in the guide, but no module in the DemoApp demonstrates them. The DemoApp is the canonical reference — gaps here mean the skill's guidance has no working example to point to.

| Missing feature | Guide section | Recommended home |
|---|---|---|
| `FieldsValidator` | Section 9 | `Forms` module — replace manual validation |
| `UseCase` protocol for networking | Section 10 | `Networking` module — add `FetchPostsUseCase` |
| `ClientProtocol` decoupling | Section 10 | `Networking` module — `NetworkingViewModel` holds `PostClient()` concrete type |
| `finish()` / `cancel()` from a non-nested coordinator | Section 7 | `Alerts` or `Onboarding` coordinator — neither calls `finish()` |
| Property-backed `ResolveXUseCase` | Section 10 | `Storage` module — demonstrate `ResolveSessionUseCase` pattern |
| `Snackbar` with `onDismiss` callback | Section 8 | `Alerts` module — only `onAction` is shown |
| `NetworkMonitor` | Section 10 | `Networking` module — one-time check or continuous observation |
| `ViewLifecycleable` hooks doing real work | Section 5 | `Onboarding` — `OnboardingViewModel` declares `ViewLifecycleable` but implements none of the methods |

---

## Small Gaps

| Location | Issue | Rule |
|---|---|---|
| `StorageViewController.makeButton` | Closures use `self?.viewModel.save(...)` without `guard let self else { return }` | Always `guard let self` after weak capture |
| `NetworkingViewController.didUpdatePosts()` | Wraps `list.reloadData()` in `dispatchOnMain { }` — inconsistent with the async path which correctly uses `Task { @MainActor [weak self] in }` | Prefer `Task { @MainActor in }` for consistency |
| `DeclarativeUIViewController.colorBar/colorBox` | Use `bar.addSubview(lbl)` inside `.with {}` to overlay a label | Legitimate exception (no ZStack; overlaying requires direct addSubview) — worth a brief inline comment |
| `ImageLoadingViewController` | Exposes `reloadData()` to the ViewModel via `CollectionViewReloadable` — slightly inverted (VM should communicate through the view protocol, not expose a UI action) | Minor; acceptable for demo clarity |

---

## Reference-Quality Modules

These are the best examples in the codebase and should be cited when writing new code.

### `Modules/Forms/FormsViewController.swift`
The most production-realistic module. Demonstrates:
- Keyboard-aware layout: `.pinBottom(to: $1.keyboardLayoutGuide.topAnchor)` ✅
- `onReturnKeyPressed` field chaining between three fields ✅
- `addToggleVisibilityButton()` on password field ✅
- `isEnabled(false)` initial state with validation-driven enable ✅
- `UIScrollView` + `setWidth(to: $1.widthAnchor)` ✅

### `Modules/CoordinatorDemo/ChildFlowCoordinator.swift`
The only module that correctly demonstrates `finish()` / `cancel()` with event propagation:
- `finish()` and `cancel()` overrides emit events before calling `super` ✅
- `onEvent: Handler<CoordinatorEvent>` propagates through nested coordinator chain ✅
- Matches the "Nested coordinator chains" section of the guide exactly ✅

### `Modules/Alerts/AlertsCoordinator.swift`
Coordinator protocol isolation done correctly:
- `AlertsCoordinatorProtocol` defined, `AppCoordinator` is not exposed ✅
- `presentCustomAlert` helper encapsulates the `CustomAlertWireframe` flow ✅
- `makeSuccessCard()` shows the custom content alert pattern ✅

### `Modules/ImageLoading/Cell/ImageDemoCell.swift`
The only cell that correctly handles the nil viewModel path:
- `thumbView.cancelImageLoad()` when `viewModel = nil` ✅
- `loadImage(from: vm.imageURL, options: vm.options)` ✅
- `setAsRoundedView(radius: 8)` on the image view ✅

### `Modules/Lists/ListsViewController.swift` + `ListsViewModel.swift`
Best collection view example:
- Pull-to-refresh: `UIRefreshControl().onValueChanged { }` ✅
- Two-section `CollectionViewable` with section headers ✅
- `.register(ListSectionHeaderView.self, kind: .header)` ✅

### `Modules/DeclarativeUI/DeclarativeUIViewController.swift`
Most comprehensive DSL showcase:
- All stack variants, alignment modes, distribution modes ✅
- Optional views, control flow (`if`, `for`, `#available`) ✅
- Constraint API examples ✅

---

## Priority Fix Order

Ordered by teaching harm (bad patterns in the DemoApp propagate to every project that reads it):

1. **Delete `Main/ViewController.swift`** — move `UserLocalStorageUseCase` to `Storage/` if worth keeping
2. **Rebase `ChildFlowViewController` on `BaseViewController`** — keeps coordinator demo intent, fixes base class
3. **Add `HomeCoordinatorProtocol`** — makes `Home` consistent with `Alerts` and `Onboarding`
4. **Add `FieldsValidator` to `Forms` module** — section 9 of the guide is completely undemonstrated
5. **Add `FetchPostsUseCase` to `Networking` module** — completes the Router → Client → UseCase chain
6. **Rename inner `OnboardingStep`** — eliminate the name collision
7. **Fix `CoordinatorDemoViewController.viewWillAppear` override** — use the hook
8. **Add `finish()` call to `AlertsCoordinator` or `OnboardingCoordinator`** — demonstrate the success exit path
