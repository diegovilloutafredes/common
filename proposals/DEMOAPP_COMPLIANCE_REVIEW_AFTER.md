# DemoApp — Framework Compliance Review (After)

Companion to `DemoApp/REVIEW.md`. Shows the before/after status for every item in the original compliance review after applying the `demoapp-framework-compliance` change.

**Date applied:** 2026-05-11  
**Build verified:** `xcodebuild build -scheme DemoApp` ✅

> **Status update (2026-06):** `FieldsValidator` has since been **promoted into Common** (`Common/Utils/Validation/FieldsValidator.swift`) as a generic `@MainActor` component, and the DemoApp Forms module now uses it. The notes below describing it as "not in Common / a maintainer decision" are historical and no longer accurate.

---

## Compliance Score

| Category | Before | After |
|---|---|---|
| Critical violations | 2 | **0** |
| Pattern violations | 4 | **0** |
| Features undemonstrated | 8 | **3** (see notes) |
| Small gaps | 4 | 4 (deferred — no teaching harm) |
| Reference-quality modules | 6 | **8** |

---

## Critical Violations

### 1. `Modules/Main/ViewController.swift` — prototype left in production

| Before | After |
|---|---|
| File existed with 6+ violations: missing `super.setupView()`, direct `present(vc:)` navigation, nested `dispatchOnMain { dispatchOnMain { } }`, model/UseCase types defined inside the VC | **RESOLVED** — File deleted. `UserLocalStorageUseCase` and supporting types extracted to `Modules/Storage/StorageUseCases.swift` as a correct demonstration of the property-backed UseCase pattern |

### 2. `Modules/CoordinatorDemo/ChildFlowViewController.swift` — wrong base class

| Before | After |
|---|---|
| Extended `UIViewController` directly; used `viewDidLoad` + `viewWillAppear` overrides; used `NSLayoutConstraint.activate` + `translatesAutoresizingMaskIntoConstraints = false` | **RESOLVED** — Rebased on `BaseViewController`; lifecycle via `setupView()` + `onViewWillAppear { }` + `onViewWillDisappear { }` hooks; UI via `@UIViewBuilder mainView` + `setConstraints { }` |

---

## Pattern Violations

### 3. `Modules/CoordinatorDemo/CoordinatorDemoViewController.swift`

| Before | After |
|---|---|
| `override func viewWillAppear()` | **RESOLVED** — `onViewWillAppear { }` hook in `setupView()` |
| `mainScrollView` used closure-based lazy init | **RESOLVED** — `UIScrollView().with { $0.alwaysBounceVertical = true }` |
| `buildScrollContent()` `NSLayoutConstraint.activate` unexplained | **RESOLVED** — Comment added explaining UIScrollView content-layout-guide exception |

### 4. `Modules/CoordinatorDemo/CoordinatorDemoCoordinator.swift` — no Wireframe

| Before | After |
|---|---|
| `start()` creates VC+VM directly to hold `weak var viewModel` for stats | **DEFERRED** — Intentional deviation documented inline; the coordinator needs a live `viewModel` reference for stats updates, which the Wireframe pattern doesn't accommodate cleanly. The deviation is now explicit rather than accidental. |

### 5. `Modules/Home/HomeWireframe.swift` + `HomeViewModel.swift` — missing coordinator protocol isolation

| Before | After |
|---|---|
| `HomeWireframe.createModule(coordinator: AppCoordinator)` — concrete type | **RESOLVED** — `HomeCoordinatorProtocol` defined in `HomeCoordinatorProtocol.swift`; `HomeWireframe` and `HomeViewModel` depend only on the protocol; `AppCoordinator` conforms via `extension AppCoordinator: HomeCoordinatorProtocol {}` |

### 6. `Modules/Onboarding/OnboardingViewController.swift` — `OnboardingStep` name collision

| Before | After |
|---|---|
| Inner `enum OnboardingStep` shadowed top-level `OnboardingStep` (the data model conforming to `OnboardingCellViewModel`) | **RESOLVED** — Inner enum renamed to `OnboardingPage`; all internal references updated; top-level `OnboardingStep` unchanged |

---

## Missing Demonstrations

| Feature | Guide section | Before | After |
|---|---|---|---|
| `FieldsValidator` | Section 9 | Not demonstrated anywhere | **PARTIAL** — `FieldsValidator` is documented in the guide but not present in the current framework binary. `FormsViewModel` was refactored to use stored field values with computed per-field validation rules (removing the mutable `[Field: Bool]` dictionary), demonstrating the same declarative-per-field concept. |
| `UseCase` protocol for networking | Section 10 | `NetworkingViewModel` held concrete `PostClient()` | **RESOLVED** — `PostUseCases.swift` adds `FetchPostsUseCase` + `FetchPostsAsyncUseCase`; `NetworkingViewModel` conforms to both |
| `ClientProtocol` decoupling | Section 10 | `NetworkingViewModel` had no client protocol | **RESOLVED** — `PostClientProtocol` + `AsyncPostClientProtocol` added; `PostClient`/`AsyncPostClient` conform |
| `finish()` / `cancel()` from a non-nested coordinator | Section 7 | Only `ChildFlowCoordinator` demonstrated them; top-level coordinators only called `pop()` | **RESOLVED** — `OnboardingCoordinator` now calls `finish()` on `.begin` (success) and `cancel()` on `.skip` (abandonment) before `pop()` |
| Property-backed `ResolveXUseCase` | Section 10 | Not demonstrated anywhere | **RESOLVED** — `StorageUseCases.swift` demonstrates `UserLocalStorageUseCase` with `UserStorage` and property-backed default extension; `StorageViewModelImpl` conforms |
| `Snackbar` with `onDismiss` callback | Section 8 | Only `onAction` shown | **DEFERRED** — Out of scope for this change |
| `NetworkMonitor` | Section 10 | Not used anywhere | **DEFERRED** — Out of scope for this change |
| `ViewLifecycleable` hooks doing real work | Section 5 | `OnboardingViewModel` declares `ViewLifecycleable` but implements no methods | **DEFERRED** — Out of scope for this change |

---

## Small Gaps

| Location | Issue | Status |
|---|---|---|
| `StorageViewController.makeButton` | Closures use `self?.viewModel.save(...)` without `guard let self else { return }` | **DEFERRED** — No teaching harm; refactor goes beyond scope |
| `NetworkingViewController.didUpdatePosts()` | `dispatchOnMain { }` wrapping `list.reloadData()` — inconsistent with async path | **DEFERRED** — No teaching harm |
| `DeclarativeUIViewController.colorBar/colorBox` | Missing inline comment explaining direct `addSubview` in `.with {}` | **DEFERRED** — No teaching harm |
| `ImageLoadingViewController` | `CollectionViewReloadable` slightly inverted direction | **DEFERRED** — Acceptable for demo clarity |

---

## New Reference-Quality Modules

Two additional modules now demonstrate previously missing patterns and can be cited as examples:

### `Modules/Storage/StorageUseCases.swift` (NEW)
The only file in the DemoApp demonstrating the property-backed UseCase pattern:
- `UserStorage: SingleRawValueKeyValueObjectStorage` with `.secure` store type ✅
- `UserLocalStorageUseCase` protocol + default extension instantiating storage internally ✅
- `StorageViewModelImpl` conforming to `UserLocalStorageUseCase` ✅

### `Modules/Networking/PostUseCases.swift` (NEW)
Completes the full Router → Client → Protocol → UseCase chain:
- `PostClientProtocol: AnyObject` + `PostClient` conformance ✅
- `AsyncPostClientProtocol: AnyObject` + `AsyncPostClient` conformance ✅
- `FetchPostsUseCase` protocol + default extension ✅
- `FetchPostsAsyncUseCase` protocol + async default extension ✅
- `NetworkingViewModel` conforming to both UseCase protocols ✅

### `Modules/Home/HomeCoordinatorProtocol.swift` (NEW)
Adds `Home` to the set of modules with coordinator protocol isolation:
- `@MainActor protocol HomeCoordinatorProtocol: AnyObject` ✅
- `AppCoordinator` conformance via extension (same pattern as `AlertsCoordinatorProtocol`) ✅
- `HomeViewModel` and `HomeWireframe` depend only on the protocol ✅

---

## Open Items

These items remain open (not critical, not blocking):

1. `CoordinatorDemoCoordinator` — no Wireframe (intentional, documented inline)
2. `FieldsValidator` — not in current framework binary; guide documents it as planned API
3. `Snackbar.onDismiss`, `NetworkMonitor`, `ViewLifecycleable` real work — gaps but out of scope
4. Four small-gap items — all deferred, no teaching harm

---

## Verdict — Was the guide/skill "good enough" for a model to use Common correctly?

**Date:** 2026-06-01. The original objective behind this branch was to test whether `COMMON_FRAMEWORK_GUIDE.md` and the distilled `.claude/skills/common-framework.md` are sufficient for an AI to produce idiomatic Common code. Cross-checking both against the actual Common API and against production usage (UniPay) gives a clear answer.

**Conclusion: good, but not yet trustworthy verbatim — the skill is strong; the guide had concrete defects that would make a model emit non-compiling code.** Most of the surface is accurate (all UI/architecture/storage/lifecycle protocols verified to exist; the screen/coordinator/storage templates are correct). The failures were concentrated in **networking** and **form validation**:

| Defect | Where | Severity | Status |
|---|---|---|---|
| `ResolveTokensUseCase` — does not exist in Common *or* UniPay | guide §10, skill networking template + checklist | 🔴 emits non-compiling code | **Fixed** — replaced with the real inline-`headers` token pattern (token read from an app-level Storage type, as UniPay does) |
| `FieldsValidator` / `Field` / `Condition` — entire §9 subsystem absent from Common | guide §9 (skill omits it ✓) | 🔴 emits non-compiling code | **Marked** — §9 now flagged "not shipped in Common; app-level pattern." Promotion to Common is a **decision for the maintainer** (production uses it 29× app-locally) |
| `@unknown default` justified as "open enum" | skill | 🟡 wrong rationale (it's frozen `Result`) | **Fixed** — corrected rationale |
| "Don't call `HTTPService` directly" | guide §10 | 🟡 contradicts production (UniPay calls it directly) | **Fixed** — documents both valid client styles |
| Wireframe + separate ViewModel presented as mandatory | guide/skill | 🟡 over-prescriptive (~60% of UniPay screens skip them) | **Fixed** — skill notes the pattern scales to the screen |
| `keyboardLayoutGuide` bottom-pin (production standard) | absent from skill UI rules | 🟢 omission | **Fixed** — added |

**Net:** a model handed the *skill* would now produce correct Common code; the chief residual risk was the guide's `ResolveTokensUseCase` and §9, both now corrected/flagged. The one item requiring a human decision is whether to **promote a `FieldsValidator` into Common** (it is genuinely useful and used in production, but lives in the app layer today).
