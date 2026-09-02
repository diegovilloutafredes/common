---
name: common-framework
description: Use when building, reviewing, refactoring, or debugging code that uses the Common iOS framework or its DSL/types — VStack/HStack, UIViewBuilder, coordinators, wireframes, VList, BaseClient/AsyncBaseClient, FieldsValidator, KeyValueStore — including in consumer apps (UniPay, Riivi, ordename, bioidentity).
---

<!-- synced-with: COMMON_FRAMEWORK_GUIDE.md @ 8c693fc (2026-09-02).
     If the guide changed since that commit, re-diff this skill against it. -->

# Common Framework — Quick Reference

This skill gives an AI everything needed to correctly use the **Common iOS framework** (UIKit + MVVM-C). Invoke before building any screen or API domain using Common.

## When this skill isn't enough → the guide

`references/COMMON_FRAMEWORK_GUIDE.md` (next to this file; a link to the framework's guide) is the deep reference. Escalate instead of inventing an API:

| Need | Guide section |
|---|---|
| async/await networking, upload, override points | §10 |
| custom alerts / `CustomAlertWireframe` | §8 + Appendix A |
| image loading options, cache policy, preloading | §17 |
| child-flow lifecycle, pop cascades, sheets | §7 |
| storage variants (collection, dynamic keys, injection) | §11 |
| environments | §16 |
| system managers (camera, biometrics, permissions, Apple login) | §18 |
| house style for framework-side code | §19 |

---

## Architecture Mental Model

```
Coordinator  → owns navigation, starts child coordinators, conforms to UseCase protocols
Wireframe    → enum factory: createModule(...) -> UIViewController  (no state, no logic)
ViewModel    → weak delegate (coordinator) + weak view (VC), conforms to ViewLifecycleable
ViewController → BaseViewModelableViewController subclass, builds UI via @UIViewBuilder mainView
View / Cell  → BaseView / BaseViewModelableCell, same mainView pattern
```

Communication directions (strict):
- VC → ViewModel: direct method calls
- ViewModel → VC: via `weak var view: ViewProtocol?`
- ViewModel → Coordinator: via `weak var delegate` or `onAction` closure
- Coordinator navigates: `push`, `pop`, `set`, `present` — VCs never navigate directly

---

## Canonical Templates

### New Screen (VC + VM + Wireframe)

```swift
// FooWireframe.swift — always enum, never struct/class
enum FooWireframe {
    @MainActor static func createModule(with delegate: BaseModuleDelegate, onAction: @escaping Handler<FooAction>) -> UIViewController {
        let vm = FooViewModel(delegate: delegate, onAction: onAction)
        return FooViewController(viewModel: vm).with { vm.view = $0 }
    }
}

// FooViewModel.swift — @MainActor: ViewLifecycleable, CollectionViewable and FieldsValidator are main-actor bound
protocol FooViewModelProtocol: ViewModel, ViewLifecycleable {}

@MainActor
final class FooViewModel {
    private weak var delegate: BaseModuleDelegate?
    private let onAction: Handler<FooAction>
    weak var view: FooViewProtocol?

    init(delegate: BaseModuleDelegate, onAction: @escaping Handler<FooAction>) {
        self.delegate = delegate
        self.onAction = onAction
    }
}

extension FooViewModel: FooViewModelProtocol {}
extension FooViewModel: ViewLifecycleable {
    func onViewDidLoad() {
        view?.addBackButton { [weak self] in self?.delegate?.onGoBackRequested() }
    }
    func onViewWillAppear() {}
    func onViewWillDisappear() {}
}

// FooViewController.swift — view protocol = only capabilities the base VC already provides
// (BackButtonAddable, ActivityIndicatorable, ScreenSizeMeasurable, KeyboardDismissable …).
// NavigationBarSetupable has NO default implementation — adopt it only if you implement setupNavigationBar().
protocol FooViewProtocol: BackButtonAddable {}

final class FooViewController: BaseViewModelableViewController<FooViewModelProtocol> {
    private lazy var titleLabel = UILabel("Title")
        .font(.appFont(style: .bold, size: 24))
        .textColor(.black)
        .numberOfLines()

    @UIViewBuilder override var mainView: UIView {
        VStack(margins: .init(top: 16, left: 16, bottom: 16, right: 16), spacing: 16) {
            titleLabel
        }.setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        backgroundColor(.white)
        set(title: "Foo")
    }
    // No initializer here: init(viewModel:) is inherited from the base class.
    // Declaring init?(coder:) (or any init) removes that inheritance and fails to compile.
}
extension FooViewController: FooViewProtocol {}
```

> **Scale the pattern to the screen.** The full VC + VM + Wireframe + view-protocol set above is the template for stateful screens. In production, simple screens commonly skip the Wireframe and the separate ViewModel: a `BaseViewController` subclass takes `OnRequested`/`OnPerformed` closures in its `init` and the coordinator wires them directly. Use the full set when there's real view-model state to hold; don't add empty ceremony for a static screen.

### Coordinator

```swift
final class AppCoordinator: BaseCoordinator {
    override func start() { push(fooViewController) }

    // Computed var — fresh instance on each navigation, no stale state
    private var fooViewController: UIViewController {
        FooWireframe.createModule(with: self) { [weak self] action in
            guard let self else { return }
            switch action {
            case .next:
                push(BarWireframe.createModule(with: self))
            case .child:
                addChildAndStart(ChildCoordinator(
                    navigationController: navigationController,
                    onPerformed: { [weak self] _ in self?.pop() }
                ))
            }
        }
    }
}
```

**The completion contract (get this right or flows silently break):**
- The child calls `finish()` when its flow *succeeds* → fires `onPerformed` exactly once.
- `cancel()` fires **automatically** when the child's entry screen leaves the nav stack (back button, swipe-back, any pop) → deliberately does **not** fire `onPerformed`.
- The parent never invokes the closure itself, and the child never calls `finish()` for abandonment.

### New API Domain (Router → Client → UseCase)

```swift
// Environment — define once per app (the Router below references it)
enum AppEnvironment: Environment {
    case production
    static var current: AppEnvironment { .production }
    static var baseURLAsString: String { "https://api.example.com" }
    // baseURL: URL? comes free from the Environment default implementation
}

// Router
enum FooRouter { case list; case detail(String); case create(Encodable) }
extension FooRouter: Endpoint {
    var baseURL: URL?   { AppEnvironment.baseURL }
    var basePath: String { "/api" }
    var version: String  { "/v1" }
    var path: String {
        switch self {
        case .list:             "/foo"
        case .detail(let id):  "/foo/\(id)"
        case .create:           "/foo"
        }
    }
    var method: HTTPMethod {
        switch self { case .create: .post; default: .get }
    }
    var headers: HTTPHeaders {
        // Resolve the auth token inline from your app's storage. There is no Common-provided
        // token protocol — the token lives in an app-level Storage type (see Storage below).
        guard let token = AuthStorage().get()?.accessToken else { return .init() }
        return .init([.authorization(bearerToken: token)])
    }
    var parameters: Encodable? {
        switch self { case .create(let p): p; default: nil }
    }
}

// Client — DEFAULT for new code: AsyncBaseClient (structured concurrency)
final class FooClient: AsyncBaseClient {
    func list() async throws -> [Foo] { try await request(FooRouter.list) }
    func create(using params: CreateFooParams) async throws -> Foo { try await request(FooRouter.create(params)) }
}

// Callback style — use when integrating with callback-based coordinator flows
protocol FooClientProtocol: AnyObject {
    func list(result: @escaping NetworkResultHandler<[Foo]>)
    func create(using params: CreateFooParams, result: @escaping NetworkResultHandler<Foo>)
}
final class CallbackFooClient: BaseClient {}
extension CallbackFooClient: FooClientProtocol {
    func list(result: @escaping NetworkResultHandler<[Foo]>) {
        request(from: #function, FooRouter.list, result: result)   // #function deduplicates in-flight
    }
    func create(using params: CreateFooParams, result: @escaping NetworkResultHandler<Foo>) {
        request(from: #function, FooRouter.create(params), result: result)
    }
}

// UseCase — match the client style: async use case over the async client
protocol FetchFooUseCase {
    func fetchFoo() async throws -> [Foo]
}
extension FetchFooUseCase {
    func fetchFoo() async throws -> [Foo] { try await FooClient().list() }
}
// Callback variant pairs with the callback client:
// extension FetchFooUseCase { func fetchFoo(onResult: @escaping NetworkResultHandler<[Foo]>) { CallbackFooClient().list(result: onResult) } }
// Conform coordinator or VC: extension MyCoordinator: FetchFooUseCase {}
```

### Storage

```swift
// Stored models conform to Storable (a typealias for Codable)
struct Foo: Storable { let value: String }

struct FooStorage {
    var type: KeyValueStore.StoreType { .secure }   // or .notSecure(.userDefaults)
    enum Keys: String { case foo }
}
extension FooStorage: SingleRawValueKeyValueObjectStorage {
    func add(item: Foo) { add(item: (.foo, item)) }
    func get() -> Foo?   { get(using: .foo) }
    func delete()         { remove(using: .foo) }
}
```

### Screen with Collection List

```swift
// The list screen's ViewModel MUST conform to CollectionViewable (item counts,
// cell view models, sizes) — the base VC reaches it at runtime; a VM without it
// compiles fine and renders an empty list.
protocol FooListViewModelProtocol: CollectionViewable, ViewModel, ViewLifecycleable {}

// BaseCollectionViewableViewController — NOT BaseViewModelableViewController — for screens with VList/HList
final class FooListViewController: BaseCollectionViewableViewController<FooListViewModelProtocol> {
    private lazy var list = VList(dataSource: self, delegate: self)   // dataSource is required — VList() does not compile
        .register(FooCell.self)
        .register(FooHeaderView.self, kind: .header)                  // optional supplementary views
        .setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }

    @UIViewBuilder override var mainView: UIView { list }
}

// FooListViewModel.swift — the cell contract the base VC calls at runtime.
// CollectionViewable = CollectionViewDataSourceable & CollectionViewDelegateable & CollectionViewSizeable.
@MainActor
final class FooListViewModel {
    weak var view: FooListViewProtocol?          // FooListViewProtocol: ScreenSizeMeasurable → screenWidth for sizes
    private var items: [FooCellViewModel] = []
}
extension FooListViewModel: CollectionViewable {
    func getNumberOfSections() -> Int { 1 }                                                   // defaulted (1)
    func getNumberOfItems(in section: Int) -> Int { items.count }                             // REQUIRED
    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { FooCell.reuseIdentifier } // REQUIRED
    func onCellForItem(in section: Int, at index: Int) -> ViewModel? { items[index] }         // REQUIRED — bound via cell.viewModel
    func onSizeForItem(in section: Int, at index: Int) -> Size { (view?.screenWidth ?? 375, 68) } // REQUIRED — (width, height) tuple
    func onItemSelected(in section: Int, at index: Int) { /* tap → delegate/snackbar */ }     // defaulted no-op
    // Also defaulted: onInsetFor(section:), onMinimumLineSpacingFor(section:), onMinimumInteritemSpacingFor(section:),
    // and the header/footer trio below. Never hand-roll UICollectionViewDataSource in the VC.
}

final class FooCell: BaseViewModelableCell<FooCellViewModelProtocol> {
    private lazy var titleLabel = UILabel().font(.appFont(style: .bold, size: 15)).textColor(.label)

    // ALL model-driven content goes here — never reference viewModel in mainView (it's nil at build time).
    // Runs after every viewModel assignment and, for @Observable models, after any tracked change.
    override func updateContent() {
        guard let viewModel else { return }
        titleLabel.text(viewModel.title)
    }

    @UIViewBuilder override var mainView: UIView {
        VStack(spacing: 4) { titleLabel }.setConstraints { $0.snap(to: $1) }
    }
}
```

**Section headers / footers:** register with `.register(View.self, kind: .header/.footer)`; the ViewModel answers three hooks per kind — `on{Header,Footer}ItemReuseIdentifierRequested(in:) -> String`, `on{Header,Footer}ItemDataSourceRequested(in:) -> ViewModel?`, `onSizeFor{Header,Footer}Item(in:) -> Size` (`(width:height:)` tuple). Size defaults to zero = not rendered; a non-zero size without a registered reuse identifier makes UIKit throw. Views subclass `BaseViewModelableReusableView<T>`. Guide §5.

---

## UI Building Rules

**Subview declarations:**
- `private lazy var` — always; never computed `var` for views that hold state

**Layout:**
- All UI via `VStack`/`HStack` — no manual `addSubview()` inside `mainView`
- `margins:` for internal padding, not wrapper views
- `setConstraints` handles `translatesAutoresizingMaskIntoConstraints` automatically
- Combine ALL constraints for a view in **one** `setConstraints {}` — calling twice overwrites
- Root content: `snap(to: $1.safeAreaLayoutGuide)`
- UIScrollView content: add `setWidth(to: $1.widthAnchor)` to prevent horizontal scroll
- Keyboard-aware forms (production standard): pin the bottom to the keyboard guide — `setConstraints { $0.snapLeadTopTrail(to: $1.safeAreaLayoutGuide); $0.pinBottom(to: $1.keyboardLayoutGuide.topAnchor) }`

**Stack alignment pitfall:**
- `alignment: .center` collapses `UIView`/`UIStackView` (no intrinsic width) → invisible
- Use `.fill` (default) + `textAlignment(.center)` on labels for visual centering
- `.center` is safe for `UILabel`, `UIImageView`, `UIButton` (they have intrinsic size)

**Stack distribution:**
- `.fill` — one view stretches to fill; use when content should expand
- `.equalSpacing` — each child keeps its size, even gaps between them
- `.fillEqually` — all children same size

**Component preferences (production standard):**
- Buttons: `UIButton(configuration: .filled()/.borderless()/.plain())` over `ActionButton`
- Cards: `VStack + .round() + .shadow()` over `CardView`
- Padded labels: `PaddingLabel(padding:)` — never wrap a `UILabel` in a container just for insets
- Pills/badges: `PillUILabel` — pill background; padding honored in measurement and drawing (survives width compression and wrapping)
- Gradients: `GradientView` — configure colors/locations/direction; never hand-roll CAGradientLayer
- Animated GIFs: `GIFImageView` (auto-pauses off-window; loops until `stopAnimating()` — loop-count metadata is ignored; `isPlayingGIF` is false while paused) — never add a GIF dependency
- Sign in with Apple: `AppleSignInButton().onTap { }` (`.adaptive` black/white by default; `init(type:style:)`) + `AppleLoginManager` kept in a property, `performLogin(from:)` once the VC is in a window (guide §18)
- Keyboard dismissal: `setupAsKeyboardDismissable()` — never hand-roll `view.onTap { endEditing }`
- `UILabel("text").numberOfLines()` — no argument defaults to 0 (unlimited)
- `imageView.loadImage(from: url)` — cache-first; auto-cancels only when `loadImage`
  is called again on the same view. In cells, call `cancelImageLoad()` in
  `prepareForReuse()` for reuse paths that don't immediately re-load.
- Options: `imageView.loadImage(from: url, options: .init(placeholder: UIImage(systemName: "photo"), transition: .fade(0.25)))`
- `ImageLoader.shared.preload(urls:)` for upcoming cells; `cancelPreloads()` when the screen goes away

**No ZStack** — achieve layering via constraints (`.sendSelfToBack()`).

---

## Lifecycle Rules

```
init(viewModel:) → loadView() [mainView assigned] → viewDidLoad → setupView()
→ viewWillAppear → viewIsAppearing → viewDidAppear
```

- `super.setupView()` always first
- `mainView`: purely declarative — no side effects, no network calls, no data reads
- Data binding in `setupView()`, not `mainView`
- Lifecycle events via hooks (`onViewIsAppearing`, `onViewWillDisappear`), not method overrides
- Observable state: read it in `onUpdateProperties()` (ViewModel) or `updateContent()` (view/cell/VC); the framework re-runs the hook on change (`ObservationMode.current`: native on 26, manual on 17–18). Never pair it with `didSet` or `setNeedsLayout`.
- Self-sizing rows (`estimatedItemSize = .automaticSize` + `preferredLayoutAttributesFitting`): `onSizeForItem` must return the list's width, not `screenWidth` — wider items are dropped and the list renders empty. Content is bound synchronously on `viewModel` assignment so measurement sees it.
- Observable view model checklist: `import Observation`; `@Observable @MainActor final class` + `@MainActor` protocol + `@MainActor static func createModule`; `@ObservationIgnored` on `weak var view`, `lazy var`s and arrays; collections behind a tracked `revision: Int` the controller compares before `reloadData()`; guard same-value writes in scroll/frame handlers; `super.updateContent()` first; events (snackbar, error) stay view-protocol calls; `setActivityIndicator(visible: isLoading)` for spinners.

---

## Networking Result Handling

```swift
fooClient.list { result in
    switch result {
    case .success(let items): updateUI(with: items)
    case .failure(let error): showError(error)
    }
}
```

No `@unknown default` — `NetworkResultHandler` wraps `Swift.Result` (frozen); the two cases are exhaustive.

---

## Fonts — AppFontFamily

Families are declared by the app, registered once at startup (no `UIAppFonts` plist entry), then used through `.appFont`. Font files must be bundle resources named after their PostScript names: `Family-Style` (`Montserrat-Bold.ttf`); the `rawValue` is the family's PostScript base name in camelCase (`varelaRound` → `VarelaRound-Regular`).

```swift
extension AppFontFamily {
    static let montserrat = AppFontFamily(rawValue: "montserrat")
}

// SceneDelegate / AppDelegate, once:
UIFont.register(fonts: [.montserrat])                                   // "ttf", all FontStyle cases; missing faces skipped
UIFont.register(fonts: [.inter], styles: [.regular, .bold], type: "otf")
UIFont.setPrimaryFamily(.montserrat)

// Anywhere:
.font(.appFont(style: .bold, size: 14))       // primary family (style defaults to .regular)
.font(.appFont(.montserrat, size: 13))        // explicit family, positional
```

- Styles: `.thin .extraLight .light .regular .medium .semiBold .bold .extraBold .black .italic`
- Unresolvable faces fall back to the system font at the matching weight — `.appFont` never fails
- Apps with a pre-existing local `appFont(style:size:)` helper keep resolving to it (Common's is `@_disfavoredOverload`); migrate by deleting the helper and calling `setPrimaryFamily`

---

## Form Validation — FieldsValidator

`FieldsValidator<Field: Hashable>` (`@MainActor`, shipped in Common) — declare rules per field, feed values, react to recomputed state. Never hand-roll validation.

```swift
private enum Field: Hashable { case email, password, confirmPassword }

// Explicit type: the fields' closures reference `validator` back — an inferred lazy type is a circular reference.
private lazy var validator: FieldsValidator<Field> = .init(
    rules: [
        .email:           [.notEmpty, .email],
        .password:        [.notEmpty, .minLength(6)],
        .confirmPassword: [.notEmpty, .matches(.password)]     // cross-field
    ],
    message: { field, rule in
        switch (field, rule) {
        case (.confirmPassword, .matches): "Passwords must match"
        default:                           rule.defaultMessage // return "" to enforce a rule silently
        }
    },
    onChange: { [weak self] state in
        guard let self else { return }
        submitButton.isEnabled(state.isValid)
        state.fields.forEach { field, fieldState in
            fieldState.message.map { self.showError(field, $0) } ?? self.clearError(field)
        }
    }
)

// Feed from the DSL:
UITextField().onEditingChanged { [weak self] in self?.validator.set($0.text, on: .email) }
```

- Rules: `.notEmpty`, `.minLength/.maxLength(n)`, `.containsLetter/Lowercase/Uppercase/Number`, `.contains(CharacterSet)`, `.email`, `.rut`, `.matches(Field)`, `.differs(from: Field)`
- Touched-state is built in — a field shows no errors until its first `set`; call `touchAll()` on a submit attempt
- `state.isValid` ignores touched-state → drive the submit button with it; `set(nil, on:)` is treated as `""`
- Where it lives: the demo keeps the validator in the `@MainActor` ViewModel and drives the VC through its view protocol (`showFieldError(field:message:)` / `clearFieldError(field:)` / `updateValidationStatus(isValid:)`); keeping it in the VC as above also works
- `.matches`/`.differs` compare against `""` for unset fields — pair `.matches` with `.notEmpty`

---

## Critical Gotchas

1. **`@MainActor` ≠ `DispatchQueue.main` in Xcode 26**: `DispatchQueue.main.async` / `dispatchOnMain` are not drained during `await fulfillment(of:)` in async test contexts. Use `Task { @MainActor in result(value) }` for callback delivery — not `DispatchQueue.main.async`.

2. **`setConstraints` stores one handler per view**: Calling it twice overwrites the first. Always combine: `view.setConstraints { $0.set(height: 44); $0.setWidth(to: $1.widthAnchor) }`.

3. **`alignment: .center` collapses `UIView` spacers**: Plain `UIView` has no intrinsic width — center alignment makes it zero-width and invisible. Use `.fill` + `textAlignment(.center)`.

4. **`viewModel` is nil in `mainView`**: In cells, all model-driven content goes in `updateContent()` (or a `viewModel didSet` for plain value models) — the view builder runs before `viewModel` is set. Assignment binds synchronously (self-sizing cells measure right after configuration); later observable changes come on the next pass. Work that must run once per assignment (an image load) goes behind a guard on the bound value; `updateContent()` may run more than once.

5. **`BaseCollectionViewableViewController` not `BaseViewModelableViewController`** for screens with `VList`/`HList`. The collection base provides all dataSource/delegate boilerplate at zero cost.

6. **Wireframe VC properties in coordinators must be computed `var`**, not stored — ensures a fresh instance on each navigation, no stale state carried across presentations.

7. **`round(corners:radius:)` does not set `clipsToBounds`** — subviews can overflow. Use `setAsRoundedView(radius:)` when overflow must be hidden (avatars, images, badges).

8. **`NavigationBarSetupable` has no default implementation** — an empty conformance does not compile; the demo VCs don't adopt it. Add it to a view protocol only when the VC implements `setupNavigationBar()`.

9. **Logger**: a dictionary literal `Logger.log(["k": v])` prints in call-site order — never pass `caller:` explicitly (it falls back to the deprecated unordered overload). `Logger.forceEnable()` is Debug-source-only and absent from the SPM binary: consumers opt in with `Logger.isRuntimeForceEnabled(true)` **then** `<Type>.shouldLog(true)`, in that order.

10. **`updateContent()` is not `updateProperties()`**: never override UIKit's `updateProperties()` in a Common subclass — the base classes own it and forward to `updateContent()`. Trigger with `setNeedsContentUpdate()`.

---

## House Style (framework-side code)

When writing code that lives in `Common/` itself (full detail: guide §19):

- 3-line filename-only header; one primary symbol per file; `// MARK: - Symbol` per type; conformances as separate MARKed `extension Type: Protocol {}` blocks at file bottom.
- Capability protocols end `-able`; `*Requestable` = upward delegate (`onXRequested`); behavior via protocol + constrained default implementation.
- Chainables: `@discardableResult func x(_:) -> Self { with { $0.x = ... } }`, one file per property.
- Closure typealiases (`Action`, `Handler<T>`, `NetworkResultHandler<T>`) — never raw `(T) -> Void` in public signatures.
- `.empty`/`.zero`/`.isNotNil`/`.isNotEmpty` over literals and negations; DocC on every public symbol; `final` leaves, `open` bases, `@MainActor` UI types; defaults on nearly every parameter.

---

## New Screen Checklist (Appendix B)

- [ ] `final class MyVC: BaseViewModelableViewController<MyVMProtocol>` (or `BaseCollectionViewableViewController` if list)
- [ ] No initializer in a `BaseViewModelableViewController` subclass — `init(viewModel:)` is inherited; declaring `init?(coder:)` removes it (custom-`init` + unavailable `init?(coder:)` is for `BaseViewController` subclasses that take closures)
- [ ] ViewModel and `createModule` are `@MainActor`
- [ ] `@UIViewBuilder override var mainView: UIView` — declarative, no side effects
- [ ] `override func setupView()` calls `super.setupView()` first
- [ ] All subviews declared as `private lazy var`
- [ ] All closures use `[weak self]` + `guard let self else { return }`
- [ ] Lifecycle logic via `onViewIsAppearing`, `onViewWillDisappear` hooks — not overrides
- [ ] Networking via UseCase conformance on the ViewModel, VC, or Coordinator (the demo conforms the ViewModel)
- [ ] Navigation fired via `onRequested`/`onAction` callback — never directly
- [ ] Forms validate with `FieldsValidator` — never hand-rolled per-field checks

## New API Domain Checklist (Appendix C)

- [ ] `enum MyRouter` — one case per endpoint
- [ ] `extension MyRouter: Endpoint` — `baseURL`, `basePath`, `version`, `path`, `method`, `headers`, `parameters`
- [ ] Auth: resolve the token inline in `headers` from an app-level Storage type (no Common token protocol exists)
- [ ] `protocol MyClientProtocol: AnyObject`
- [ ] `final class MyClient: BaseClient {}` (empty body)
- [ ] `extension MyClient: MyClientProtocol` — `request(from: #function, ...)` calls
- [ ] `protocol MyUseCase` + `extension MyUseCase` with default implementation
- [ ] Conform the relevant ViewController or Coordinator to `MyUseCase`
