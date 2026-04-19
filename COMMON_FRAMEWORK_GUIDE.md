# Common Framework Usage Guide

This guide documents how to use the **Common** framework to build UI, wire modules, handle navigation, and perform networking in iOS projects. It is a portable reference for any project that adopts Common as a dependency.

> **Minimum deployment target:** iOS 16.0+  
> **UI paradigm:** UIKit with a declarative DSL that mimics SwiftUI syntax  
> **Note:** `Common.xcframework` is a pre-compiled binary. This guide is inferred from real production usage — treat it as a living reference, not a generated API spec. Every file importing Common must also `import UIKit`.

---

## Table of Contents

1. [Declarative UI DSL](#1-declarative-ui-dsl)
2. [Layout — VStack, HStack, Stack](#2-layout--vstack-hstack-stack)
3. [Method Chaining and Fluent Extensions](#3-method-chaining-and-fluent-extensions)
4. [Constraint System](#4-constraint-system)
5. [ViewController Lifecycle](#5-viewcontroller-lifecycle)
6. [Module Wiring — Wireframe Pattern](#6-module-wiring--wireframe-pattern)
7. [Coordinator Navigation](#7-coordinator-navigation)
8. [Reusable Components](#8-reusable-components)
9. [Form Validation — FieldsValidator](#9-form-validation--fieldsvalidator)
10. [Networking](#10-networking)
11. [Storage Layer](#11-storage-layer)
12. [Defaults and Constants](#12-defaults-and-constants)
13. [Styling Conventions](#13-styling-conventions)
14. [Core Protocols and Typealiases](#14-core-protocols-and-typealiases)
15. [Common Pitfalls and Best Practices](#15-common-pitfalls-and-best-practices)
16. [Environment](#16-environment)
17. [Appendix A — alertView() helper](#appendix-a--alertview-helper)
18. [Appendix B — New screen checklist](#appendix-b--new-screen-checklist)
19. [Appendix C — New API domain checklist](#appendix-c--new-api-domain-checklist)

---

## 1. Declarative UI DSL

Common provides two result builders that enable a SwiftUI-like declarative syntax on top of UIKit.

### `@UIViewBuilder`

Converts a list of `UIView` instances into a **single parent `UIView`**. Used on the `mainView` property and on any helper method that returns a `UIView`.

### `@UIViewsBuilder` (alias for `ArrayBuilder<UIView>`)

Converts a list of `UIView` instances into an **array `[UIView]`**. Used inside stack view closures. Supports conditionals and optionals:

```swift
// - Multiple views:    buildBlock(_ items: T...) -> [T]
// - if/else:          buildEither(first:) / buildEither(second:)
// - if let/optional:  buildOptional(_ items: [T]?) -> [T]
// - Array expression: buildExpression(_ item: [T]) -> [T]
```

### `UIView` convenience initializer

`UIView` has a convenience init accepting `@UIViewsBuilder`:

```swift
UIView {
    UILabel("Title")
    UIImageView(image: someImage)
    UILabel("Subtitle")
}
```

### The `mainView` pattern

Both `BaseViewController` and `BaseView` expose a `mainView` property decorated with `@UIViewBuilder`. Override it to declare your view hierarchy. The framework automatically assigns it as the root view in `loadView()` — never set `self.view` directly.

```swift
final class MyViewController: BaseViewController {
    @UIViewBuilder
    override var mainView: UIView {
        VStack(spacing: 16) {
            UILabel("Hello")
            UILabel("World")
        }.setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }
}
```

`@UIViewBuilder` can also be applied to private helper methods to decompose complex layouts:

```swift
@UIViewBuilder
private func headerView() -> UIView {
    VStack(alignment: .center, spacing: 12) {
        avatarImageView
        nameLabel
        emailLabel
    }
}
```

### Conditionals in the DSL

```swift
VStack {
    UILabel("Always visible")
    if showDetails { UILabel("Detail text") }
    if let subtitle = optionalSubtitle { UILabel(subtitle) }
}
```

### Do's and Don'ts

- **Do** use `@UIViewBuilder` on `mainView` overrides and helper methods that return a single view.
- **Do** use `@UIViewsBuilder` when composing arrays of views inside stacks.
- **Do** use `if`/`if let` directly in stack builders.
- **Don't** use `addSubview()` manually inside `mainView` — let the DSL handle the hierarchy.
- **Don't** call `self.view = ...` directly — `BaseViewController.loadView()` does this.

---

## 2. Layout — VStack, HStack, Stack

`VStack` and `HStack` are convenience subclasses of `Stack` (which extends `UIStackView`). They preconfigure the axis and accept children via `@UIViewsBuilder`.

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `alignment` | `UIStackView.Alignment` | Cross-axis alignment: `.fill` (default), `.center`, `.leading`, `.trailing`, `.top`, `.bottom` |
| `distribution` | `UIStackView.Distribution` | `.fill` (default), `.fillEqually`, `.fillProportionally`, `.equalSpacing`, `.equalCentering` |
| `margins` | `UIEdgeInsets` | Internal padding via `layoutMargins` (relative arrangement enabled by default) |
| `spacing` | `CGFloat` | Distance between arranged subviews |

`Stack` automatically enables `isLayoutMarginsRelativeArrangement = true` and `insetsLayoutMarginsFromSafeArea = false`, so `margins` are absolute inner padding.

### Stack — Single-child wrapper

`Stack` wraps a single child with optional margins — useful for padding a view without adding a full stack:

```swift
Stack(margins: .init(top: 0, left: 24, bottom: 64, right: 24)) {
    actionButton
}
```

### Nesting stacks

```swift
VStack(distribution: .equalSpacing, margins: .init(top: 16, left: 16, bottom: 24, right: 16)) {
    VStack(alignment: .leading, spacing: 8) {
        UILabel("Title").font(.boldSystemFont(ofSize: 28))
        UILabel("Subtitle").font(.systemFont(ofSize: 14))
    }
    HStack(alignment: .center, spacing: 12) {
        actionButton
        cancelButton
    }
}
```

### Default margins constant

```swift
VStack(margins: .DefaultValues.StackView.margins, spacing: .DefaultValues.StackView.spacing) {
    // content
}
```

### Distribution modes

| Distribution | Use when... |
|---|---|
| `.fill` | One view should expand to fill remaining space |
| `.fillEqually` | All children should be the same size |
| `.fillProportionally` | Children size proportionally to their intrinsic content size |
| `.equalSpacing` | Even spacing between children, views keep their natural size |
| `.equalCentering` | Equal distance between the centers of children |

### Flexible spacing

Common does **not** provide a SwiftUI-like `Spacer`. Instead:

```swift
// Even spacing between children
VStack(distribution: .equalSpacing) { ... }

// Push content to the bottom
VStack(distribution: .fill) {
    UILabel("Content at top")
    UIView()  // flexible space — expands to fill
    actionButton
}

// Edge padding via margins
VStack(margins: .init(top: 16, left: 24, bottom: 0, right: 24)) { ... }
```

### UIScrollView wrapping

For scrollable content, the inner stack must be pinned to the scroll view's `contentLayoutGuide` (which defines the scrollable area) and have its width tied to `frameLayoutGuide.widthAnchor` (to prevent horizontal scrolling). The `setConstraints` DSL pins to the direct superview's anchors — not to `contentLayoutGuide` — so you must use manual `NSLayoutConstraint` inside a `.with { }` closure:

```swift
UIScrollView()
    .setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    .with { scroll in
        let contentStack = VStack(
            margins: .DefaultValues.StackView.margins,
            spacing: 16
        ) {
            // content
        }
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            contentStack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
        ])
    }
```

> The `.with { }` + `NSLayoutConstraint.activate` approach is the correct exception for scroll view content. All other layout should go through `setConstraints`.
>
> - **contentLayoutGuide** anchors define the scrollable content area
> - **frameLayoutGuide.widthAnchor** prevents horizontal scrolling

### Dynamic children from arrays

```swift
HStack(spacing: 32) {
    digitsRanges.map { range in
        HStack(spacing: 8) { range.map { index in textFields[index] } }
    }
}
```

### Do's and Don'ts

- **Do** use `margins` instead of wrapping stacks in padding views.
- **Do** set `alignment: .leading` or `.center` when children shouldn't stretch to full width.
- **Don't** manually set `axis` — use `VStack` or `HStack`.
- **Don't** use ZStack — it is not used in this codebase; achieve layering via constraints.

---

## 3. Method Chaining and Fluent Extensions

All UIKit views can be configured with fluent, chainable methods powered by the `Withable` protocol. Every method returns `Self`.

### Withable (reference types) / ValueWithable (value types)

```swift
// Reference types (UIView subclasses)
public protocol Withable: AnyObject {
    @discardableResult func with(_ closure: (_ instance: Self) -> Void) -> Self
}

// Value types (structs)
public protocol ValueWithable {
    @discardableResult func with(_ closure: (_ instance: inout Self) -> Void) -> Self
}
```

### The `.with { }` pattern

Use when you need to access properties not exposed by fluent methods, or for multi-step configuration:

```swift
// Nested configuration
UIButton(configuration: .filled())
    .with {
        $0.configuration?.background.strokeColor = .black
        $0.configuration?.background.strokeWidth = 1
    }

// Conditional setup
UILabel(viewModel.text)
    .with {
        guard let attributed = viewModel.attributedText else { return }
        $0.attributedText(attributed)
    }

// Sheet presentation controller
UIViewController()
    .with {
        $0.sheetPresentationController?
            .detents([.custom { $0.maximumDetentValue * 0.75 }])
            .prefersGrabberVisible(false)
            .preferredCornerRadius(8)
    }

// Works on structs too (via ValueWithable)
registerParams.with { $0.password = encryptedPassword }
```

### UIView — Visual styling

| Modifier | Description |
|----------|-------------|
| `.backgroundColor(_ color:)` | Background color |
| `.tintColor(_ color:)` | Tint color |
| `.borderColor(_ color:)` | Layer border color |
| `.borderWidth(_ width:)` | Layer border width |
| `.setAsRoundedView()` | Corner radius = half of shortest dimension |
| `.setAsRoundedView(radius:)` | Specific corner radius |
| `.cornerRadius(_ radius:)` | Alias for corner radius |
| `.alpha(_ value:)` | View alpha |
| `.clipsToBounds(_ value:)` | Clips subviews to bounds |
| `.contentMode(_ mode:)` | Content mode (for images) |
| `.isHidden(_ value:)` | Visibility |
| `.isUserInteractionEnabled(_ value:)` | Interaction |
| `.shadow(color:offset:opacity:radius:)` | Drop shadow |
| `.shadowColor(_ color:)` | Shadow color only |
| `.shadowOffset(_ offset:)` | Shadow offset only |
| `.shadowOpacity(_ opacity:)` | Shadow opacity only |
| `.shadowRadius(_ radius:)` | Shadow radius only |

### UILabel

```swift
UILabel("Hello World")
    .font(.appFont(style: .bold, size: 16))
    .textColor(.black)
    .numberOfLines()             // 0 (unlimited) — no argument needed
    .numberOfLines(2)            // specific limit
    .textAlignment(.center)
    .adjustsFontSizeToFitWidth()
    .text("updated value")       // imperative update
    .textWithTransition("new value")  // animated text change
```

### UITextField

```swift
UITextField()
    .borderColor(.gray600)
    .borderWidth(1)
    .contentType(.emailAddress)
    .font(.appFont(size: 16))
    .keyboardType(.emailAddress)
    .placeholder("Enter email", color: .gray600, font: .appFont(size: 16))
    .setAsRoundedView(radius: 4)
    .setRatio(327/56)
    .textColor(.black)
    .with { $0.leftView(.init(frame: .init(x: 0, y: 0, width: 16, height: $0.frame.height))) }
```

**Event handlers:**

```swift
.onEditingChanged { [weak self] textField in
    guard let self else { return }
    fieldsValidator.set(textField.text, on: .email)
}
.onEditingDidBegin { textField in /* focus gained */ }
.onEditingDidEnd { textField in /* focus lost */ }
.onReturnKeyPressed { _ in self.onActionButtonPressed() }
```

**Input restrictions:**

```swift
.allowedChars("0123456789")   // character whitelist
.maxLength(6)                  // character limit
.addToggleVisibilityButton()   // show/hide password toggle
```

### UIButton

**Modern `UIButton.Configuration` approach (preferred):**

```swift
// Filled — solid background
UIButton(configuration: .filled()
    .attributedTitle(.init("Continue", attributes: .init()
        .with { $0.font = .appFont(style: .bold, size: 14) }))
    .baseBackgroundColor(.black)
    .baseForegroundColor(.white)
    .cornerStyle(.capsule)
)
.isEnabled(false)
.onTap(onActionButtonPressed)
.setRatio(327/60)

// Borderless — text + optional icon
UIButton(configuration: .borderless()
    .attributedTitle(.init("See detail", attributes: .init()
        .with { $0.font = .appFont(style: .bold, size: 14) }))
    .baseForegroundColor(.backgroundPurple01)
    .image(.chevronRight.withRenderingMode(.alwaysTemplate))
    .imagePadding(8)
    .imagePlacement(.trailing)
)

// Outlined — filled with white bg + stroke
UIButton(configuration: .filled()
    .attributedTitle(.init("Cancel", attributes: .init()
        .with { $0.font = .appFont(style: .bold, size: 14) }))
    .baseBackgroundColor(.white)
    .baseForegroundColor(.black)
    .cornerStyle(.capsule)
    .with {
        $0.background.strokeColor = .black
        $0.background.strokeWidth = 1
    }
)
```

**Simple button (no configuration):**

```swift
UIButton()
    .font(.appFont(style: .bold, size: 12))
    .title("Recover password")
    .titleColor(.black)
    .onTap { self.onRequested(.recoverPassword) }
```

**Button methods:**

| Method | Effect |
|--------|--------|
| `.onTap { ... }` / `.onTap(methodRef)` | Tap action |
| `.isEnabled(bool)` | Enable/disable |
| `.font(.appFont(size: 14))` | Title font (non-configuration buttons) |
| `.title("Confirm")` | Title for `.normal` state |
| `.titleColor(.color)` | Title color |
| `.symbol("star.fill")` | SF Symbol image |
| `.configuration(config)` | Update `UIButton.Configuration` imperatively |

### UIImageView

```swift
UIImageView(image: .logo)
    .setRatio()
    .tintColor(.backgroundPurple01)
    .contentMode(.scaleAspectFit)
```

### UISwitch

```swift
UISwitch()
    .on(.black)
    .onValueChanged { [weak self] toggle in
        guard let self else { return }
        handleToggle(toggle.isOn)
    }
```

### Event handling and layout callbacks

```swift
// Tap on any view
UILabel("Clickable")
    .isUserInteractionEnabled(true)
    .onTap { _ in handleTap() }

// Called when view is added to a superview
anyView.onMoveToSuperview { view, superview in /* setup */ }

// Called on each layout pass — use for geometry-dependent work like rounding
anyView.onLayoutSubviews { view in view.setAsRoundedView() }
```

---

## 4. Constraint System

Common provides a constraint API centered around `setConstraints`, which is activated automatically when the view is added to a superview.

### `setConstraints`

```swift
// Shorthand: $0 = view, $1 = superview
myView.setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }

// Named parameters
myView.setConstraints { view, superview in
    view.alignCenter(with: superview)
    view.setWidth(to: superview.widthAnchor, multiplier: 0.8)
}

// Capture self when referencing other views
backgroundImageView.setConstraints { [weak self] in guard let self else { return }
    $0.snapLeadTrail(to: $1)
    $0.alignCenter(with: titleLabel)
    $0.sendSelfToBack()
}
```

### Snap methods (edge pinning)

| Method | Edges pinned |
|--------|-------------|
| `.snap(to:insets:)` | All four edges |
| `.snapLeadTrail(to:insets:)` | Leading + Trailing |
| `.snapTopBottom(to:)` | Top + Bottom |
| `.snapLeadTop(to:)` | Leading + Top |
| `.snapTopTrail(to:)` | Top + Trailing |
| `.snapLeadBottom(to:)` | Leading + Bottom |
| `.snapBottomTrail(to:)` | Bottom + Trailing |
| `.snapLeadTopTrail(to:)` | Leading + Top + Trailing |
| `.snapTopTrailBottom(to:)` | Top + Trailing + Bottom |
| `.snapLeadBottomTrail(to:insets:)` | Leading + Bottom + Trailing |
| `.snapTopLeadBottom(to:)` | Top + Leading + Bottom |
| `.snapBottom(to:)` | Bottom only |
| `.pinBottom(to:)` | Bottom to a specific anchor |

### Center alignment

| Method | Description |
|--------|-------------|
| `.alignCenterX(with:)` | Horizontal center |
| `.alignCenterY(with:)` | Vertical center |
| `.alignCenter(with:)` | Both axes |

### Sizing

| Method | Description |
|--------|-------------|
| `.set(width:)` | Fixed width constant |
| `.set(height:)` | Fixed height constant |
| `.setWidth(to:multiplier:)` | Width relative to an anchor |
| `.setHeight(to:multiplier:)` | Height relative to an anchor |
| `.setRatio(_ ratio:)` | Aspect ratio (width/height); default `1.0` (square) |
| `.sendSelfToBack()` | Z-order: send behind siblings |

### Aspect ratio shortcuts

```swift
UIImageView(image: .logo).setRatio()          // intrinsic aspect ratio
UITextField().setRatio(327/56)                // explicit ratio
UIView().setAsRoundedView()                   // height = width, fully rounded
UIView().setAsRoundedView(radius: 4)          // specific corner radius
```

### Practical examples

```swift
// Full-screen, pinned to safe area
contentView.setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }

// Centered card, 80% of width
cardView.setConstraints { view, superview in
    view.alignCenter(with: superview)
    view.setWidth(to: superview.widthAnchor, multiplier: 0.8)
}

// Bottom-anchored bar
bottomBar.setConstraints { $0.snapLeadBottomTrail(to: $1) }

// Full layout with overlapping background element
@UIViewBuilder
override var mainView: UIView {
    VStack(distribution: .equalSpacing) {
        headerView()
        VStack(alignment: .center) { titleLabel; subtitleLabel }
        Stack(margins: .init(top: 0, left: 24, bottom: 40, right: 24)) { actionButton }
    }.setConstraints {
        $0.setHeight(to: $1.heightAnchor, multiplier: 0.7)
        $0.snapLeadBottomTrail(to: $1.safeAreaLayoutGuide)
    }

    backgroundImageView
        .setConstraints { [weak self] in guard let self else { return }
            $0.snapLeadTrail(to: $1)
            $0.alignCenter(with: titleLabel)
            $0.sendSelfToBack()
        }
}
```

### Content priority

```swift
label.contentCompressionResistance(priority: .required, axis: .vertical)
label.contentHugging(priority: .defaultLow, axis: .horizontal)
```

### Do's and Don'ts

- **Do** use `setConstraints` — it handles `translatesAutoresizingMaskIntoConstraints` and deferred activation.
- **Do** use `snap(to: $1.safeAreaLayoutGuide)` for root-level content.
- **Don't** activate constraints manually via `NSLayoutConstraint.activate` — except inside `UIScrollView.with { }` closures for content layout guide binding (see UIScrollView wrapping in section 2).
- **Don't** confuse `.setRatio()` (1:1 square) with `.setRatio(w/h)` — always be explicit.

---

## 5. ViewController Lifecycle

### `BaseViewController`

The minimal base class. All view controllers inherit from it — never use `UIViewController` directly.

- `mainView` property (override with `@UIViewBuilder`)
- `loadView()` sets `self.view = mainView` automatically
- `setupView()` called in `viewDidLoad()` — override for post-load configuration; **always call `super.setupView()`**
- Default status bar style: `.darkContent`
- Swipe-to-go-back gesture restored automatically

```swift
final class SimpleViewController: BaseViewController {
    @UIViewBuilder
    override var mainView: UIView {
        VStack { UILabel("Hello") }
            .setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        backgroundColor(.white)
        set(title: "Screen Title")
        setupAsKeyboardDismissable()
    }
}
```

### `BaseViewModelableViewController<T: ViewModel>`

Extends `BaseViewController` with a typed view model injected via `required init(viewModel:)`. Forwards lifecycle to the view model if it conforms to `ViewLifecycleable`.

```swift
final class ProfileViewController: BaseViewModelableViewController<ProfileViewModel> {
    @UIViewBuilder
    override var mainView: UIView {
        VStack(spacing: 16) {
            UILabel(viewModel.userName)
            UILabel(viewModel.email)
        }.setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        addBackButton { [weak self] in self?.viewModel.onBackTapped() }
    }
}
```

### `BaseViewModelableView<T: ViewModel>`

For custom views with a view model:

```swift
final class ItemView: BaseViewModelableView<ItemViewModel> {
    @UIViewBuilder
    override var mainView: UIView {
        HStack(spacing: 12) {
            UILabel(viewModel.title)
            UILabel(viewModel.subtitle)
        }
    }
}
```

### `BaseViewModelableCell<T: ViewModel>`

For collection/table view cells:

```swift
final class OnboardingCell: BaseViewModelableCell<OnboardingCellViewModel> {
    @UIViewBuilder
    override var mainView: UIView { /* ... */ }
}
```

### Lifecycle hooks

Use closures instead of overriding lifecycle methods — all lifecycle logic stays in `setupView()`:

| Hook | When it fires |
|------|--------------|
| `onViewWillAppear { vc in ... }` | Before the view appears |
| `onViewDidAppear { vc in ... }` | After the view appears |
| `onViewIsAppearing { vc in ... }` | First appearance — safe for layout-dependent setup |
| `onViewWillDisappear { vc in ... }` | Before the view disappears |
| `onLayoutSubviews { vc in ... }` | Each layout pass |

```swift
override func setupView() {
    super.setupView()
    onViewWillAppear { $0.hideNavigationBar(animated: false) }
    onViewWillDisappear { $0.showNavigationBar(animated: false) }
    onViewIsAppearing { [weak self] _ in guard let self else { return }
        fetchData()
    }
}
```

### System notification observers

```swift
observe(.onDidBecomeActive)    { [weak self] in guard let self else { return }; resume() }
observe(.onDidBecomeIdle)      { [weak self] in guard let self else { return }; pauseWork() }
observe(.onWillResignActive)   { [weak self] in guard let self else { return }; saveState() }
observe(.onSceneDidDisconnect) { [weak self] in guard let self else { return }; cleanup() }
```

### Activity indicators

Always pair with `stopActivityIndicator` — including on failure paths:

```swift
startActivityIndicator()
stopActivityIndicator()

// With status message
startActivityIndicator("Loading...", onMessageLabel: { label = $0 })

// With completion callback
stopActivityIndicator { [weak self] in guard let self else { return }
    present(viewController: nextScreen)
}
```

### Navigation bar

```swift
set(title: "Create Account")
setNavigationBar(backgroundColor: .white, titleFont: .appFont(style: .bold, size: 16))
addBackButton { [weak self] in self?.onRequested(.goBack) }
addBackButton(.symbol("chevron.left")) { /* custom action */ }
hidesBackButton(true)
hideNavigationBar(animated: false)
showNavigationBar(animated: false)
titleView(UIImageView(image: .logo).setRatio(80/24))
```

### Lifecycle order

1. `init(viewModel:)` — ViewModel injected
2. `loadView()` — `mainView` assigned as root view
3. `viewDidLoad()` → `setupView()` — configure background, nav bar, bind data
4. `viewWillLayoutSubviews()` / `viewDidLayoutSubviews()`
5. `viewWillAppear(_:)` — swipe-to-go-back gesture re-enabled
6. `viewIsAppearing(_:)` — view in hierarchy, size/traits are final
7. `viewDidAppear(_:)`
8. `viewWillDisappear(_:)`

### Lazy property pattern

Declare complex subviews as `private lazy var` — they capture `self` safely and are evaluated once:

```swift
private lazy var titleLabel = UILabel()
    .font(.boldSystemFont(ofSize: 24))
    .textColor(.black)
    .numberOfLines(0)

private lazy var actionButton = UIButton(configuration: .filled()
    .attributedTitle(.init("Continue", attributes: .init()
        .with { $0.font = .appFont(style: .bold, size: 14) }))
    .cornerStyle(.capsule)
).onTap { [weak self] in self?.viewModel.onContinue() }
```

### Convenience methods

```swift
backgroundColor(.systemBackground)
setupAsKeyboardDismissable()
dismissKeyboard()
animate { /* UIView animations */ }
dispatchOnMain { /* main-thread work */ }
dispatchOnMainAfter(.now() + 0.3) { /* delayed work */ }
```

### Do's and Don'ts

- **Do** always call `super.setupView()` — it sets the default background color.
- **Do** use `lazy var` for subviews that need `self` references.
- **Do** keep `mainView` purely declarative — no side effects, no network calls.
- **Don't** override `loadView()` — let `BaseViewController` handle it.
- **Don't** configure data in `mainView` — use `setupView()` for data binding.

---

## 6. Module Wiring — Wireframe Pattern

Each screen is wired using a stateless `enum` wireframe with a static factory method.

### Structure

```
ModuleName/
├── ModuleNameViewController.swift   — UI (mainView + setupView)
├── ModuleNameViewModel.swift        — Business logic + delegate
└── ModuleNameWireframe.swift        — Factory that wires VC + VM
```

### Wireframe implementation

```swift
enum ProfileWireframe {
    static func createModule(with delegate: BaseModuleDelegate) -> UIViewController {
        let viewModel = ProfileViewModel(delegate: delegate)
        return ProfileViewController(viewModel: viewModel)
            .with { viewModel.view = $0 }
    }
}
```

- **Enum** (not struct/class) — purely a namespace, no state
- **`createModule`** is the single factory entry point
- The coordinator passes itself as `delegate`
- `.with { viewModel.view = $0 }` establishes the ViewModel-to-ViewController back-reference after init

### ViewModel pattern

```swift
final class ProfileViewModel {
    weak var delegate: BaseModuleDelegate?
    weak var view: ProfileViewController?

    init(delegate: BaseModuleDelegate) {
        self.delegate = delegate
    }

    func onBackTapped() {
        delegate?.onGoBackRequested()
    }
}
```

### `BaseModuleDelegate`

A typealias composing four protocols that coordinators implement:

```swift
public typealias BaseModuleDelegate = ActivityControllerRequestable
    & AlertRequestable
    & DismissRequestable
    & GoBackRequestable
```

| Protocol | Method | Purpose |
|----------|--------|---------|
| `GoBackRequestable` | `onGoBackRequested()` | Pop the current screen |
| `DismissRequestable` | `onDismissRequested()` | Dismiss modal |
| `AlertRequestable` | `onPresentAlertRequested(...)` | Show an alert |
| `ActivityControllerRequestable` | `onPresentActivityControllerRequested(with:)` | Show share sheet |

### Extended delegates

```swift
protocol ProfileModuleDelegate: BaseModuleDelegate {
    func onEditProfileRequested()
    func onLogoutRequested()
}
```

### OnRequested / OnPerformed pattern

An alternative, closure-based approach used throughout this codebase. ViewControllers communicate intent via typed enums passed as constructor closures:

```swift
final class LoginViewController: BaseViewController {
    enum OnRequested { case register, recoverPassword }
    enum OnPerformed { case login(isWhiteListed: Bool, transactionId: String) }

    private let onRequested: Handler<OnRequested>
    private let onPerformed: Handler<OnPerformed>

    init(
        onRequested: @escaping Handler<OnRequested>,
        onPerformed: @escaping Handler<OnPerformed>
    ) {
        self.onRequested = onRequested
        self.onPerformed = onPerformed
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}
```

- **OnRequested** — user wants to navigate somewhere (coordinator decides where)
- **OnPerformed** — user completed an action (coordinator reacts to the result)

### Do's and Don'ts

- **Do** use an `enum` for wireframes — stateless factories only.
- **Do** use `weak` references for `delegate` and `view` in view models.
- **Do** mark `init?(coder:)` as `@available(*, unavailable)` on every ViewController.
- **Don't** put business logic in the wireframe — it only wires dependencies.
- **Don't** let view controllers navigate directly — they call delegate methods or fire callbacks.

---

## 7. Coordinator Navigation

### `BaseCoordinator`

Manages a `UINavigationController`, child coordinators, and conforms to all navigation protocols.

```swift
open class BaseCoordinator: NSObject, Coordinator, BaseModuleDelegate {
    public let navigationController: UINavigationController
    public let onPerformed: Handler<Coordinator>?
    public var childCoordinators: [Coordinator] = []

    open func start() {}  // Override to push the first screen
}
```

### Starting a coordinator

```swift
class AppCoordinator: BaseCoordinator {
    override func start() {
        let vc = HomeWireframe.createModule(with: self)
        push(vc)
    }
}

// In SceneDelegate:
let nav = UINavigationController()
let coordinator = AppCoordinator(navigationController: nav)
coordinator.start()
window?.rootViewController = nav
```

### Navigation protocols

#### `Navigationable` — stack navigation

```swift
push(viewController, animated: true)

pop(.back)                          // one screen back
pop(.toRoot)                        // to root
pop(.to(viewController: someVC))    // to specific VC

set(viewController)                 // replace entire stack
set([vc1, vc2, vc3])
```

#### `Dismissable`

```swift
dismiss(.topMost)    // dismiss topmost presented VC
dismiss(.fromRoot)   // dismiss from root presenter
```

#### `Presentable`

```swift
present(.overCurrent, viewController: vc)
present(.dismissingCurrent, viewController: vc)
```

#### `ActivityIndicatorable`

```swift
startActivityIndicator()
startActivityIndicator(with: .blue)
stopActivityIndicator()
```

#### `AlertPresentable`

```swift
presentAlertView(type: .genericError, acceptAction: nil, cancelAction: nil)
presentAlertView(type: .customAlert(title: "Oops", message: "Something failed"), acceptAction: { _ in }, cancelAction: nil)
```

### Child coordinators

```swift
class MainCoordinator: BaseCoordinator {
    func startProfileFlow() {
        let child = ProfileCoordinator(
            navigationController: navigationController,
            onPerformed: { [weak self] coordinator in
                self?.removeChild(coordinator)
            }
        )
        addChildAndStart(child)
    }
}
```

| Method | Description |
|--------|-------------|
| `addChild(_ coordinator:)` | Store reference |
| `addChildAndStart(_ coordinator:)` | Store + call `start()` |
| `getChild<T>(_ type:)` | Retrieve child by type |
| `removeChild(_ coordinator:)` | Remove from array |

### Typical coordinator flow

View controller properties should be **computed vars**, not stored — this ensures a fresh instance on each navigation, avoiding stale state:

```swift
private var loginViewController: UIViewController {
    LoginViewController(
        onRequested: { [weak self] action in guard let self else { return }
            switch action {
            case .register: push(registerViewController, animated: true)
            }
        },
        onPerformed: { [weak self] action in guard let self else { return }
            switch action {
            case .login: set(homeViewController, animated: true)
            }
        }
    )
}
```

### Lifecycle hooks from coordinator

Lifecycle hooks can be attached to VC instances in the coordinator — one of the few places you call these outside `setupView()`:

```swift
private var splashViewController: UIViewController {
    SplashViewController()
        .onViewWillAppear { $0.hideNavigationBar(animated: false) }
        .onViewDidAppear { [weak self] _ in guard let self else { return }
            dispatchOnMainAfter(.now() + 0.3) { [weak self] in guard let self else { return }
                set(initialViewController, animated: true)
            }
        }
        .onViewWillDisappear { $0.showNavigationBar(animated: false) }
}
```

### Coordinators conforming to UseCases

Coordinators can conform to business logic protocols directly:

```swift
extension AppCoordinator: LogoutUseCase {}
extension AppCoordinator: HandlePendingDataUseCase {}
```

### Sheet presentation

```swift
.with {
    $0.sheetPresentationController?
        .detents([.custom { $0.maximumDetentValue * 0.75 }])
        .prefersGrabberVisible(false)
        .preferredCornerRadius(16)
}
```

Common detent sizes: `0.45` (small), `0.75` (medium), `0.8` (large), `0.9625` (near-fullscreen).

### Default delegate behavior

`BaseCoordinator` provides default implementations:
- `onGoBackRequested()` → calls `pop()`
- `onDismissRequested()` → calls `dismiss()`

Override in subclasses for custom behavior.

### Do's and Don'ts

- **Do** always clean up child coordinators via `removeChild` when their flow ends.
- **Do** use computed vars for VC properties — avoids stale state.
- **Don't** present or push directly from a ViewController — route through the coordinator.
- **Don't** hold strong references to child coordinators outside `childCoordinators`.

---

## 8. Reusable Components

### `BaseView`

Custom views use the same `mainView` + `setupView()` pattern as view controllers:

```swift
final class BadgeView: BaseView {
    @UIViewBuilder
    override var mainView: UIView {
        HStack(alignment: .center, spacing: 4) {
            UIView().backgroundColor(.green).set(width: 8).set(height: 8).setAsRoundedView()
            UILabel("Active").font(.systemFont(ofSize: 12))
        }
    }
}
```

`BaseView` automatically adds `mainView` snapped to all edges, calls `setupView()` after init, and sets `requiresConstraintBasedLayout = true`.

### `ActionButton`

Themed, rounded button:

```swift
ActionButton("Continue")                                     // Default filled theme
ActionButton("Cancel", theme: DefaultButtonTheme.border)     // Border theme
ActionButton("Submit", isEnabled: false)                     // Disabled
ActionButton("Go", shouldApplyDefaultRatio: false)           // No aspect ratio
```

Default aspect ratio: `327/40`. Built-in themes: `DefaultButtonTheme.filled`, `DefaultButtonTheme.border`.

Custom theme via the `ButtonTheme` protocol:

```swift
public protocol ButtonTheme {
    var backgroundColor: UIColor { get }
    var borderColor: UIColor { get }
    var borderWidth: Double { get }
    var titleColor: UIColor { get }
    var titleFont: UIFont { get }
}
```

### `CardView`

```swift
CardView(viewModel: CardViewModelPayload(
    leftImage: UIImage(systemName: "person"),
    title: "John Doe",
    content: "Developer",
    rightImage: UIImage(systemName: "chevron.right")
))
```

### `Separator`

```swift
Separator()                               // Black, 1pt height
Separator(color: .gray400, height: 0.5)  // thin line
Separator(color: .gray200, height: 16)   // thick spacer
myView.addSeparator(color: .gray, height: 1)  // convenience extension
```

### `Footer`

```swift
Footer(image: .asset(.poweredByTrustColored))
```

### `Snackbar`

```swift
Snackbar.show(.init(message: "Saved successfully"))

Snackbar.show(.init(
    message: "Security PIN created",
    duration: .custom(1.5),    // .short (1s), .medium (3s), .long (5s), .custom(TimeInterval)
    actionTitle: "Undo",
    onAction: { /* undo */ },
    onDismiss: { [weak self] in guard let self else { return }
        onPerformed(.passwordUpdate)
    }
))
```

Only one snackbar is shown at a time — a new one dismisses the previous.

### `HList` and `VList`

`UICollectionView`-based scrollable lists:

```swift
private lazy var list = HList(
    dataSource: self,
    delegate: self
) {
    $0.minimumInteritemSpacing(.zero)
    $0.minimumLineSpacing(.zero)
}
.clipsToBounds(false)
.isPagingEnabled(true)
.register(OnboardingCell.self)
```

Cells subclass `BaseViewModelableCell<T>` and use `@UIViewBuilder` for layout. Always call `.register(CellType.self)` before use.

### `CustomAlertWireframe`

Build alert content declaratively, then present via the wireframe:

```swift
// 1. Build the alert view (see Appendix A for alertView() helper)
let alert = alertView(
    title: "Delete account",
    subtitle: "Are you sure?",
    actionTitle: "Yes, delete",
    cancelTitle: "Cancel",
    onAction: { [weak self] in
        guard let self else { return }
        dismiss(animated: true) { self.deleteAccount() }
    },
    onCancel: nil
)

// 2. Present it
let vc = CustomAlertWireframe.createModule(alert) { [weak self] in
    guard let self else { return }
    dismiss(animated: true)
}
present(vc, animated: true)
```

### `CircularProgressView`

```swift
CircularProgressView()
    .borderColor(.white)
    .borderWidth(1)
    .setAsRoundedView()
    .setProgress(from: 0.5, duration: 30)
    .setColor(progressColor)
```

### `CircularActivityIndicatorView`

```swift
CircularActivityIndicatorView(
    colors: [.gray200],
    lineCap: .square,
    lineWidth: 16
)
.setRatio()
.startAnimating()
```

### Base classes summary

| Class | Extends | Purpose |
|-------|---------|---------|
| `BaseView` | `UIView` | Custom views with `mainView` pattern |
| `BaseButton` | `UIButton` | Custom buttons with `setupView()` hook |
| `BaseLabel` | `UILabel` | Custom labels with `setupView()` hook |
| `BaseTextField` | `UITextField` | Custom text fields with `setupView()` hook |

All base classes: disable `NSCoder` init, set `requiresConstraintBasedLayout = true`, provide `setupView()` hook.

---

## 9. Form Validation — FieldsValidator

A declarative validation system for form fields.

### Setup

```swift
private lazy var fieldsValidator = FieldsValidator(
    initialConditions: [
        .email: [.notEmpty(.empty)],
        .password: [.notEmpty(.empty)]
    ],
    onEvaluate: { (fields, fieldValue) in
        switch fieldValue.field {
        case .email:
            [.isValidEmail(fieldValue.newValue), .notEmpty(fieldValue.newValue)]
        case .password:
            [
                .length(fieldValue.newValue, 7, >),
                .containsLetters(fieldValue.newValue),
                .containsNumber(fieldValue.newValue),
                .notEmpty(fieldValue.newValue)
            ]
        default: []
        }
    },
    onStatus: { [weak self] result in
        guard let self else { return }
        actionButton.isEnabled(result.status)

        textFields.values.forEach { $0.borderColor(.gray600) }
        errorLabels.values.forEach { $0.text(.empty) }

        guard !result.status else { return }

        result.unmetConditionsFields.forEach { field, conditions in
            conditions.forEach { condition in
                textFields[field]?.borderColor(.error)
                errorLabels[field]?.text(condition.asErrorText)
            }
        }
    }
)
```

### Feeding values

```swift
UITextField()
    .onEditingChanged { [weak self] in
        guard let self else { return }
        fieldsValidator.set($0.text, on: .email)
    }
```

### Available fields

`Field` enum: `.email`, `.password`, `.repeatPassword`, `.dni`, `.name`, `.lastName`, `.phoneNumber`, `.custom(String)`

### Available conditions

| Condition | Description |
|-----------|-------------|
| `.notEmpty(value)` | Not empty |
| `.isValidEmail(value)` | Valid email format |
| `.isValidRUT(value)` | Valid Chilean RUT |
| `.length(value, n, op)` | Length compared with operator (`>`, `>=`, etc.) |
| `.containsLetters(value)` | At least one letter |
| `.containsNumber(value)` | At least one digit |
| `.containsUppercase(value)` | At least one uppercase |
| `.containsLowercase(value)` | At least one lowercase |
| `.containsCharacterSet(value, set)` | Chars from a `CharacterSet` |
| `.equal(value1, value2)` | Two values equal |
| `.notEqual(value1, value2)` | Two values not equal |

### Status

- `fieldsValidator.status` — `Bool`, all conditions met
- `result.unmetConditionsFields` — `[Field: [Condition]]`, which fields failed and why

---

## 10. Networking

### Chain summary

```
Router (enum: Endpoint) → Client (BaseClient subclass) → UseCase (protocol + default impl)
```

### Router (Endpoint)

```swift
enum ProductRouter {
    case list
    case create(Encodable)
    case detail(String)
}

extension ProductRouter: Endpoint {
    var baseURL: URL? { AppEnvironment.baseURL }
    var basePath: String { "/api" }
    var version: String { "/v1" }

    var path: String {
        switch self {
        case .list:           "/products"
        case .create:         "/products"
        case .detail(let id): "/products/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .list, .detail: .get
        case .create:        .post
        }
    }

    var headers: HTTPHeaders {
        .init()
        .with {
            guard let accessToken else { return }
            $0.add(.authorization(bearerToken: accessToken))
        }
    }

    var parameters: Encodable? {
        switch self {
        case .create(let p): p
        default: nil
        }
    }
}

// Attach token resolution
extension ProductRouter: ResolveTokensUseCase {}
```

URL construction: `baseURL + basePath + version + path`  
Parameter encoding: POST → JSON body (snake_case keys), GET → URL-encoded (snake_case keys)

### Client

```swift
protocol ProductClientProtocol: AnyObject {
    func list(result: @escaping NetworkResultHandler<[Product]>)
    func create(using parameters: CreateProductParameters, result: @escaping NetworkResultHandler<Product>)
}

final class ProductClient: BaseClient {}

extension ProductClient: ProductClientProtocol {
    func list(result: @escaping NetworkResultHandler<[Product]>) {
        request(from: #function, ProductRouter.list, result: result)
    }
    func create(using parameters: CreateProductParameters, result: @escaping NetworkResultHandler<Product>) {
        request(from: #function, ProductRouter.create(parameters), result: result)
    }
}
```

`BaseClient.request(from:_:result:)` cancels any in-flight request keyed by the same function identifier before starting a new one. Always pass `#function` as the first argument so duplicate taps don't stack requests.

### BaseResponse wrapper

```swift
struct BaseResponse<T: Codable>: Codable {
    let code: String
    let message: String
    let status: String
    var data: T?
}
extension BaseResponse: ValueWithable {}
```

### Result handler usage

```swift
productClient.list { result in
    switch result {
    case .success(let products): updateUI(with: products)
    case .failure(let error):    showError(error)
    @unknown default: break
    }
}
```

Always include `@unknown default` — `NetworkResultHandler` uses an open enum.

### UseCase pattern

```swift
protocol FetchProductsUseCase {
    func fetchProducts(onResult: @escaping NetworkResultHandler<[Product]>)
}

extension FetchProductsUseCase {
    private var productClient: ProductClientProtocol { ProductClient() }

    func fetchProducts(onResult: @escaping NetworkResultHandler<[Product]>) {
        productClient.list(result: onResult)
    }
}
```

**Protocol composition** — a UseCase can require other UseCases:

```swift
protocol CheckoutUseCase: ResolveUserUseCase, FetchProductsUseCase {
    func checkout(cart: Cart, onResult: @escaping NetworkEmptyResultHandler)
}

extension CheckoutUseCase {
    private var checkoutClient: CheckoutClientProtocol { CheckoutClient() }

    func checkout(cart: Cart, onResult: @escaping NetworkEmptyResultHandler) {
        guard let user else { onResult(.failure(.requestError("not_logged_in"))); return }
        checkoutClient.submit(.init(userId: user.id, cart: cart), result: onResult)
    }
}
```

Conform the relevant class:

```swift
extension CartViewController: CheckoutUseCase {}
extension AppCoordinator: LogoutUseCase {}
```

### Property-backed UseCases

UseCases don't have to call a network — they can expose storage as computed properties:

```swift
protocol ResolveSessionUseCase: AnyObject {
    var session: Session? { get set }
}

extension ResolveSessionUseCase {
    private var sessionStorage: SessionStorage { .init() }

    var session: Session? {
        get { sessionStorage.get() }
        set { newValue != nil ? sessionStorage.add(item: newValue!) : sessionStorage.delete() }
    }
}
```

### Error handling

```swift
enum LoginError: String, Stringable {
    case invalidCredentials = "INVALID_CREDENTIALS"
    case invalidParameters  = "INVALID_PARAMS"

    var asString: String {
        switch self {
        case .invalidCredentials: "Invalid username or password"
        case .invalidParameters:  "User is not enabled to continue"
        }
    }
}

extension NetworkError {
    var asLoginError: LoginError? {
        switch self {
        case .responseError(_, let json, _):
            .init(rawValue: json["code"] as? String ?? .empty)
        default: nil
        }
    }
}
```

### File upload (multipart)

```swift
func upload(using parameters: UploadParameters, result: @escaping NetworkResultHandler<EmptyResponse>) {
    HTTPService.upload(multipart: parameters.asMultipart, to: UploadRouter.upload, result: result)
}

extension UploadParameters {
    var asMultipart: MultipartRequest {
        .init()
        .with {
            $0.add(key: "photo", fileName: "image.jpg", fileMimeType: "image/jpeg", fileData: imageData)
            $0.add(key: "entity_id", value: entityId)
        }
    }
}
```

### NetworkMonitor

```swift
// One-time check
guard NetworkMonitor.shared.isConnected else {
    Snackbar.show(.init(message: "No internet connection"))
    return
}

// Continuous observation
NetworkMonitor.shared.onStatusChanged = { [weak self] isConnected, _ in guard let self else { return }
    isConnected ? resumeSync() : showOfflineBanner()
}
```

### Do's and Don'ts

- **Do** define routes as enum cases conforming to `Endpoint`.
- **Do** use the UseCase pattern for reusable, testable networking logic.
- **Don't** call `HTTPService` directly — go through a `BaseClient` subclass via `request(from: #function, ...)`.
- **Don't** encode parameters manually — `Endpoint` handles encoding based on HTTP method.

---

## 11. Storage Layer

### Backends

| Type | Backend | Use for |
|------|---------|---------|
| `.notSecure(.userDefaults)` | `UserDefaults` | Preferences, non-sensitive settings |
| `.notSecure(.files)` | Documents directory | Larger non-sensitive data |
| `.secure` | Keychain | Tokens, credentials, sensitive data |

All stored values must conform to `Storable` (which is `Codable`).

### `SingleRawValueKeyValueObjectStorage`

The primary abstraction for single-item stores:

```swift
protocol UserStorageProtocol: SingleRawValueKeyValueObjectStorage {}

struct UserStorage {
    var type: KeyValueStore.StoreType { .secure }
    enum Keys: String { case user }
}

extension UserStorage: UserStorageProtocol {
    func add(item: User) { add(item: (.user, item)) }
    func delete()        { remove(using: .user) }
    func get() -> User?  { get(using: .user) }
}
```

### Collection storage

For lists, manage the array yourself:

```swift
extension OrderStorage: OrderStorageProtocol {
    func add(_ order: Order) {
        var current = get() ?? []
        current.append(order)
        add(item: (.orders, current))
    }
    func get() -> [Order]? { get(using: .orders) }
    func delete()           { remove(using: .orders) }
}
```

### Dynamic key storage

When the key is determined at runtime:

```swift
private var store: KeyValueStore { .init(type: .secure) }

func save(_ items: [Item], forId id: String) { store.add(item: (id, items)) }
func load(forId id: String) -> [Item]        { store.get(using: id) ?? [] }
func delete(forId id: String)                { store.remove(using: id) }
```

### Resolve protocols

Expose storage through `Resolve*` protocols for clean injection:

```swift
protocol ResolveUserStorage {
    var userStorage: UserStorageProtocol { get }
}

extension ResolveUserStorage {
    var userStorage: UserStorageProtocol { UserStorage() }
}
```

### Do's and Don'ts

- **Do** use `.secure` for any sensitive data (tokens, keys).
- **Don't** store secrets in `.notSecure` stores.

---

## 12. Defaults and Constants

### `CGFloat.DefaultValues`

```swift
CGFloat.DefaultValues.StackView.topMargin      // 16
CGFloat.DefaultValues.StackView.leftMargin     // 16
CGFloat.DefaultValues.StackView.bottomMargin   // 16
CGFloat.DefaultValues.StackView.rightMargin    // 16
CGFloat.DefaultValues.StackView.spacing        // 16

CGFloat.DefaultValues.Button.cornerRadius      // 8
CGFloat.DefaultValues.TextField.cornerRadius   // 8
CGFloat.DefaultValues.View.cornerRadius        // 16
CGFloat.DefaultValues.BottomSheet.cornerRadius // 8
CGFloat.DefaultValues.AlertView.cornerRadius   // 16
CGFloat.DefaultValues.Cell.cornerRadius        // 4
```

### `UIEdgeInsets.DefaultValues`

```swift
UIEdgeInsets.DefaultValues.StackView.margins
// UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
```

### `String.DefaultValues`

```swift
String.DefaultValues.Alerts.acceptActionTitle  // "Aceptar"
String.DefaultValues.Alerts.cancelActionTitle  // "Cancelar"
String.DefaultValues.Alerts.title              // "Atención"
String.DefaultValues.Alerts.message            // "Ha ocurrido un error, vuelve a intentarlo"
String.DefaultValues.App.name                  // Bundle display name
String.DefaultValues.UIElements.goBack         // "Volver"
```

### Extending defaults

```swift
extension CGFloat {
    enum MyAppDefaults {
        static var cardSpacing: CGFloat { 12 }
        static var sectionPadding: CGFloat { 24 }
    }
}
```

### Do's and Don'ts

- **Do** use `DefaultValues` constants for consistent spacing across screens.
- **Don't** hardcode magic numbers — reference or define named constants.

---

## 13. Styling Conventions

### Fonts

```swift
.font(.appFont(size: 16))                                     // regular, default family
.font(.appFont(style: .bold, size: 14))
.font(.appFont(style: .medium, size: 16))
.font(.appFont(style: .semiBold, size: 14))
.font(.appFont(style: .extraBold, size: 24))
.font(.appFont(style: .black, size: 22))                      // heaviest weight
.font(.appFont(.varelaRound, style: .regular, size: 12))      // alternate family
```

**Styles:** `.regular`, `.medium`, `.semiBold`, `.bold`, `.extraBold`, `.black`  
**Families:** `.montserrat` (default), `.varelaRound`

### Colors

```swift
// Grayscale
.gray100, .gray200, .gray300, .gray400, .gray500, .gray600, .gray700

// Semantic
.error, .danger

// Brand
.backgroundPurple01, .backgroundPurple02, .backgroundCyan01, .backgroundCyan03

// Standard
.black, .white
.black.withAlphaComponent(0.5)
```

### Images

```swift
// Named (from asset catalog)
UIImageView(image: .close)
UIImageView(image: .chevronRight)
UIImageView(image: .exclamationMark)

// Asset-based (from Common framework)
Footer(image: .asset(.poweredByTrustColored))

// SF Symbols
UIButton().image(.symbol("xmark"))
UIImageView(image: .symbol("chevron.down"))

// Template rendering (for tinting)
UIImageView(image: .chevronRight.withRenderingMode(.alwaysTemplate))
    .tintColor(.backgroundPurple01)
```

---

## 14. Core Protocols and Typealiases

### Closure typealiases

| Type | Signature |
|------|-----------|
| `Handler<T>` | `(T) -> Void` |
| `CompletionHandler` | `(() -> Void)?` |
| `Action` | `() -> Void` |
| `EmptyResultHandler` | `(Result<Void, Error>) -> Void` |
| `NetworkResultHandler<T>` | `(Result<T, NetworkError>) -> Void` |
| `NetworkEmptyResultHandler` | `(EmptyResult<NetworkError>) -> Void` |

### Key protocols

| Protocol | Purpose |
|----------|---------|
| `ViewModel` | Base protocol for view models |
| `Stringable` | Type with `asString: String` |
| `Withable` | Enables `.with { }` on reference types |
| `ValueWithable` | Enables `.with { }` on value types (structs) |
| `Endpoint` | API route definition |
| `SingleRawValueKeyValueObjectStorage` | Single-item key-value storage |
| `ContentReloadable` | Views that can reload their content |
| `ViewLifecycleable` | View lifecycle event hooks |

---

## 15. Common Pitfalls and Best Practices

### Do

- **Always use `[weak self]` + `guard let self else { return }`** in closures to avoid retain cycles.
- **Set width on scroll content** (`.setWidth(to: $1.widthAnchor)`) to prevent horizontal scroll.
- **Use `.setRatio()` on images** to maintain aspect ratios.
- **Mark `init?(coder:)` unavailable** on every ViewController.
- **Prefer `.filled()` configuration** for primary action buttons, `.borderless()` for links.
- **Use `dispatchOnMain { }`** for UI updates from background threads.
- **Use `lazy var`** for subviews that need `self` references.

### Don't

- **Don't use storyboards or xibs** — all UI is programmatic via `@UIViewBuilder`.
- **Don't create view controllers directly in coordinators** — use computed properties or Wireframes.
- **Don't store strong references to coordinators in view controllers** — communicate via closures.
- **Don't call `.numberOfLines(0)` explicitly** — call `.numberOfLines()` with no argument (defaults to 0).
- **Don't forget `.register(CellType.self)`** on HList/VList before use.
- **Don't hardcode magic numbers** — use `DefaultValues` constants.
- **Don't use ZStack** — it's not used in this codebase.

### Utilities

```swift
// Main thread dispatch
dispatchOnMain { updateUI() }
dispatchOnMainAfter(.now() + 0.5) { animate() }

// Haptics
view.vibrate()
view.shake()

// String formatting
string.removeRUTFormat()
string.formatAsRUT()
string.removeCurrencyFormat()
string.asCurrency
string.asDecimalNumber
string.masked()
string.maskedEmail
```

---

## 16. Environment

```swift
enum AppEnvironment {
    case dev
    case prod
}

extension AppEnvironment: Environment {
    static var current: AppEnvironment { .prod }

    static var baseURLAsString: String {
        switch current {
        case .dev:  "https://api.dev.yourapp.com"
        case .prod: "https://api.yourapp.com"
        }
    }
}
```

Access in routers via `AppEnvironment.baseURL` (a `URL?` computed from `baseURLAsString`).

---

## Appendix A — alertView() helper

This helper is not part of the framework — implement it in your project to wrap `CustomAlertWireframe`:

```swift
func alertView(
    icon: UIImage = .symbol("exclamationmark.circle.fill")!,
    tintColor: UIColor = .systemYellow,
    title: String,
    subtitle: String,
    textField: UITextField? = nil,
    actionTitle: String? = nil,
    cancelTitle: String? = nil,
    onAction: CompletionHandler = nil,
    onCancel: CompletionHandler = nil
) -> UIView {
    VStack(distribution: .equalSpacing, margins: .init(top: 24, left: 24, bottom: 24, right: 24)) {
        VStack(alignment: .center) {
            UIImageView(image: icon)
                .tintColor(tintColor)
                .setRatio()
                .setConstraints { $0.setWidth(to: $1.widthAnchor, multiplier: 0.25) }
        }

        VStack(spacing: 16) {
            UILabel(title)
                .font(.appFont(style: .extraBold, size: 24))
                .numberOfLines()
                .textAlignment(.center)
            UILabel(subtitle)
                .font(.appFont(size: 14))
                .numberOfLines()
                .textAlignment(.center)
        }

        if let textField { textField }

        VStack(spacing: 16) {
            if let cancelTitle, let onCancel {
                UIButton(configuration: .filled()
                    .attributedTitle(.init(cancelTitle, attributes: .init()
                        .with { $0.font = .appFont(style: .bold, size: 14) }))
                    .baseBackgroundColor(.white)
                    .baseForegroundColor(.black)
                    .cornerStyle(.capsule)
                    .with { $0.background.strokeColor = .black; $0.background.strokeWidth = 1 }
                )
                .onTap(onCancel)
                .setRatio(278/40)
            }

            if let actionTitle, let onAction {
                UIButton(configuration: .filled()
                    .attributedTitle(.init(actionTitle, attributes: .init()
                        .with { $0.font = .appFont(style: .bold, size: 14) }))
                    .baseBackgroundColor(.black)
                    .baseForegroundColor(.white)
                    .cornerStyle(.capsule)
                )
                .onTap(onAction)
                .setRatio(278/40)
            }
        }
    }
    .backgroundColor(.white)
    .setRatio()
}
```

---

## Appendix B — New screen checklist

- [ ] `final class MyViewController: BaseViewController` (or `BaseViewModelableViewController<VM>`)
- [ ] Custom `init` with callback closures; `required init?(coder:)` marked `@available(*, unavailable)`
- [ ] `@UIViewBuilder override var mainView: UIView` with `VStack`/`HStack` layout
- [ ] `override func setupView()` calls `super.setupView()` first
- [ ] Lifecycle logic uses `onViewIsAppearing`, `onViewWillDisappear` hooks — not overrides
- [ ] All closures capture `[weak self]` and immediately `guard let self else { return }`
- [ ] Network calls go through a `UseCase` — view controller or coordinator conforms, calls method directly
- [ ] Navigation fired via callback to coordinator (`onRequested(.action)`)

---

## Appendix C — New API domain checklist

- [ ] `enum MyRouter` with one case per endpoint
- [ ] `extension MyRouter: Endpoint` — implement `baseURL`, `basePath`, `version`, `path`, `method`, `headers`, `parameters`
- [ ] `extension MyRouter: ResolveTokensUseCase` if the endpoint requires authentication
- [ ] `protocol MyClientProtocol: AnyObject` with method signatures using `NetworkResultHandler<T>`
- [ ] `final class MyClient: BaseClient` (empty body)
- [ ] `extension MyClient: MyClientProtocol` with `HTTPService.request(...)` calls
- [ ] `protocol MyUseCase` + `extension MyUseCase` with default implementation
- [ ] Conform the relevant ViewController or Coordinator to `MyUseCase`
