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
17. [Image Loading](#17-image-loading)
18. [Appendix A — alertView() helper](#appendix-a--alertview-helper)
19. [Appendix B — New screen checklist](#appendix-b--new-screen-checklist)
20. [Appendix C — New API domain checklist](#appendix-c--new-api-domain-checklist)

---

## 1. Declarative UI DSL

Common provides two result builders that enable a SwiftUI-like declarative syntax on top of UIKit.

### `@UIViewBuilder`

Converts a list of `UIView` instances into a **single parent `UIView`**. Used on the `mainView` property and on any helper method that returns a `UIView`.

### `@UIViewsBuilder` (alias for `ArrayBuilder<UIView>`)

Converts a list of `UIView` instances into an **array `[UIView]`**. Used inside stack view closures. Supports conditionals and optionals:

```swift
// - Multiple views:      buildBlock(_ items: [T]...) -> [T]
// - if/else:             buildEither(first:) / buildEither(second:)
// - if let/optional:     buildOptional(_ items: [T]?) -> [T]
// - for loop:            buildArray(_ components: [[T]]) -> [T]
// - Array expression:    buildExpression(_ item: [T]) -> [T]
// - Optional expression: buildExpression(_ item: T?) -> [T]  — nil values are silently dropped
// - #available:          buildLimitedAvailability(_ component: [T]) -> [T]
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
    if #available(iOS 16, *) { UILabel("iOS 16+ only") }

    // Optional UIView? drops in directly — nil values are removed from layout with no gap
    let badge: UIView? = hasUnread ? badgeView : nil
    badge   // rendered when non-nil; skipped entirely when nil
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

Use the `UIScrollView { content }` builder init. Pin the inner stack to the scroll view with `setConstraints`, then set its width to the scroll view's `widthAnchor` to prevent horizontal scrolling:

```swift
UIScrollView {
    VStack(
        margins: .DefaultValues.StackView.margins,
        spacing: 16
    ) {
        // content
    }
    .setConstraints {
        $0.snap(to: $1)
        $0.setWidth(to: $1.widthAnchor)
    }
}
.setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
```

> When pinning a subview to a `UIScrollView` via Auto Layout, the scroll view's own anchors (`topAnchor`, `leadingAnchor`, etc.) map to the **content layout guide** — the scrollable area. `setWidth(to: $1.widthAnchor)` uses the scroll view's frame width, which prevents horizontal scrolling. Both effects are achieved through `setConstraints` — no manual `NSLayoutConstraint.activate` needed.

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
| `.round(corners:radius:)` | Sets `cornerRadius` + `maskedCorners` — **does not set `clipsToBounds`** |
| `.setAsRoundedView()` | Pill shape (radius = half height), sets `clipsToBounds = true`, re-registers on layout |
| `.setAsRoundedView(radius:)` | Specific radius, sets `clipsToBounds = true` |
| `.cornerRadius(_ radius:)` | Raw `cornerRadius` setter only |
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

> **`round()` vs `setAsRoundedView()`** — choose based on whether subviews should be clipped:
> - `round(corners:radius:)` rounds the view's background but **subviews can overflow** the rounded boundary. Use for decorative rounding where child views may extend to the edge.
> - `setAsRoundedView()` / `setAsRoundedView(radius:)` calls `clipsToBounds(true)` first, then rounds. Subviews are clipped to the corner boundary. Use for avatars, badges, and image containers where overflow must be hidden.
> - `round(corners:radius:)` also accepts a `CACornerMask` to round only specific corners: `.layerMinXMinYCorner` (top-left), `.layerMaxXMinYCorner` (top-right), `.layerMinXMaxYCorner` (bottom-left), `.layerMaxXMaxYCorner` (bottom-right).

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
| `.snapCenter(to:)` | Center in a UIView or UILayoutGuide without affecting size |

### Sizing

| Method | Description |
|--------|-------------|
| `.set(width:)` | Fixed width constant |
| `.set(height:)` | Fixed height constant |
| `.set(minWidth:)` | Minimum width (≥ constant) |
| `.set(maxWidth:)` | Maximum width (≤ constant) |
| `.set(minHeight:)` | Minimum height (≥ constant) |
| `.set(maxHeight:)` | Maximum height (≤ constant) |
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

### `NSLayoutConstraint` fluent modifiers

```swift
// Adjust the constant after creation
constraint.constant(8)

// Lower priority so the constraint can be broken gracefully
constraint.priority(.defaultHigh)

// Chain both
someView.widthAnchor.constraint(equalToConstant: 120)
    .constant(120).priority(.defaultHigh)
```

### Do's and Don'ts

- **Do** use `setConstraints` — it handles `translatesAutoresizingMaskIntoConstraints` and deferred activation.
- **Do** use `snap(to: $1.safeAreaLayoutGuide)` for root-level content.
- **Do** combine all constraints for a view into a **single** `setConstraints { }` call — calling it twice overwrites the first handler (only one handler is stored per view via associated object).
- **Don't** activate constraints manually via `NSLayoutConstraint.activate` — except inside `UIScrollView.with { }` closures for content layout guide binding (see UIScrollView wrapping in section 2).
- **Don't** confuse `.setRatio()` (1:1 square) with `.setRatio(w/h)` — always be explicit.
- **Don't** use the default `.fill` distribution in HStack/VStack when arranged subviews have explicit size constraints — it will silently stretch one view to fill remaining space. Use `.equalSpacing` when each child keeps its own size.

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

### `BaseCollectionViewableViewController`

View controllers that own a `VList` or `HList` must subclass `BaseCollectionViewableViewController` — **not** `BaseViewModelableViewController`. The collection-view base class provides all `UICollectionViewDataSource`, `UICollectionViewDelegate`, and `UICollectionViewDelegateFlowLayout` boilerplate automatically; subclasses add none.

```swift
final class ProductsViewController: BaseCollectionViewableViewController<ProductsViewModelProtocol> {
    private lazy var list = VList()
        .register(ProductCell.self)
        .setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }

    @UIViewBuilder
    override var mainView: UIView { list }

    override func setupView() {
        super.setupView()
        list.dataSource = self
        list.delegate = self
    }
}
```

The base class accesses the ViewModel via `viewModel as? CollectionViewable` at runtime — the generic constraint on `ViewModelType` is intentionally absent because Swift's existential type system prevents protocol types from satisfying generic protocol constraints.

Override `bottomInsetForLastCollectionSection()` when the screen sits above a tab bar (default returns `.zero`).

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

For collection/table view cells, always use `viewModel` `didSet` to update content — `mainView` is built once in `init` and the `viewModel` property is `nil` at that point:

```swift
// Protocol — defines what the cell reads
protocol ListItemCellViewModel: ViewModel {
    var title: String { get }
    var subtitle: String { get }
    var accentColor: UIColor { get }
}

// Cell — layout in mainView, content in viewModel didSet
final class ListItemCell: BaseViewModelableCell<ListItemCellViewModel> {
    private lazy var titleLabel = UILabel().font(.boldSystemFont(ofSize: 15)).textColor(.label)
    private lazy var subtitleLabel = UILabel().font(.systemFont(ofSize: 12)).textColor(.secondaryLabel)

    override var viewModel: ListItemCellViewModel? {
        didSet {
            guard let vm = viewModel else { return }
            titleLabel.text(vm.title)
            subtitleLabel.text(vm.subtitle)
        }
    }

    @UIViewBuilder override var mainView: UIView {
        VStack(spacing: 2) { titleLabel; subtitleLabel }
            .setConstraints { $0.snap(to: $1) }
    }

    override func setupCell() {
        super.setupCell()
        backgroundColor(.clear)
    }
}
```

> **Critical**: Never reference `viewModel` inside `mainView` — it is `nil` when the view builder runs. All model-driven updates go in `viewModel didSet`.

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

`addChildAndStart` stores the child and calls `start()`. When the child's view controller is eventually popped off the navigation stack, `BaseCoordinator` removes the child from `childCoordinators` automatically via KVO — no manual `removeChild` call is needed in `onPerformed`. The `onPerformed` closure is for the parent to react to the result (e.g. pop a screen, show the next one):

```swift
class AppCoordinator: BaseCoordinator {
    func showSettingsFlow() {
        let child = SettingsCoordinator(
            navigationController: navigationController,
            onPerformed: { [weak self] _ in self?.pop() }
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
| `removeChild(_ coordinator:)` | Remove from array (rarely needed manually) |

### finish() vs cancel()

`BaseCoordinator` distinguishes between two exit paths:

- **`finish()`** — the flow completed successfully. Triggers `onPerformed`, which the parent uses to navigate forward or pop the child's screen.
- **`cancel()`** — the user abandoned the flow (e.g. swipe-back). Does NOT trigger `onPerformed`. The parent observes this implicitly; UIKit already popped the VC.

Override both when the child needs to emit events or clean up:

```swift
final class CheckoutCoordinator: BaseCoordinator {
    override func finish() {
        // notify parent of success before handing control back
        super.finish()  // triggers onPerformed
    }

    override func cancel() {
        // user bailed — clean up, do NOT call onPerformed
        super.cancel()
    }
}
```

### Detecting swipe-back cancels from a ViewController

UIKit fires `viewWillDisappear` when a VC is being popped by a back-gesture. `isMovingFromParent` is `true` only during a real pop (not a push on top). Use this to bridge the UIKit event into `cancel()`:

```swift
final class CheckoutViewController: UIViewController {
    var onCancel: (() -> Void)?

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent { onCancel?() }
    }
}

// In the coordinator's start():
vc.onCancel = { [weak self] in self?.cancel() }
```

> **Important:** Do not use `navigationController(_:didShow:animated:)` or KVO alone for detecting back-gestures — `viewWillDisappear + isMovingFromParent` is the reliable cross-version pattern.

### Coordinator protocol isolation

ViewModels and Wireframes should depend on a coordinator *protocol*, not the concrete coordinator class. This keeps modules independently testable and prevents import cycles:

```swift
// Define the protocol in the module
@MainActor
protocol CheckoutCoordinatorProtocol: AnyObject {
    func showConfirmation(order: Order)
    func showError(_ error: Error)
}

// Wireframe takes the protocol, not AppCoordinator
enum CheckoutWireframe {
    static func createModule(coordinator: CheckoutCoordinatorProtocol) -> UIViewController {
        let vm = CheckoutViewModel(coordinator: coordinator)
        return CheckoutViewController(viewModel: vm)
            .with { vm.view = $0 }
    }
}

// The concrete coordinator conforms
final class CheckoutCoordinator: BaseCoordinator, CheckoutCoordinatorProtocol {
    override func start() {
        push(CheckoutWireframe.createModule(coordinator: self))
    }
    func showConfirmation(order: Order) { push(ConfirmationWireframe.createModule(order: order)) }
    func showError(_ error: Error) { presentAlertView(type: .customAlert(title: "Error", message: error.localizedDescription), acceptAction: nil, cancelAction: nil) }
}
```

### Nested coordinator chains

For multi-level flows where each depth level can go deeper, pass an `onEvent` closure through the chain so a single hub coordinator tracks the entire tree:

Define an event struct and use `Handler<T>` from Common so call sites are named, not positional:

```swift
struct FlowEvent {
    let message: String
    let delta: Int   // +1 coordinator started, -1 finished or cancelled
}

final class HubCoordinator: BaseCoordinator {
    private var activeFlowCount = 0

    func startDeepFlow(maxDepth: Int) {
        let child = FlowCoordinator(
            navigationController: navigationController,
            depth: 1,
            maxDepth: maxDepth,
            onEvent: { [weak self] event in
                self?.activeFlowCount += event.delta
            },
            onPerformed: { [weak self] _ in self?.pop() }
        )
        addChildAndStart(child)
    }
}

final class FlowCoordinator: BaseCoordinator {
    private let depth: Int
    private let maxDepth: Int
    private let onEvent: Handler<FlowEvent>

    override func start() {
        push(FlowViewController(depth: depth, maxDepth: maxDepth))
        onEvent(FlowEvent(message: "Depth \(depth) started", delta: +1))
    }
    override func finish() {
        onEvent(FlowEvent(message: "Depth \(depth) finished", delta: -1))
        super.finish()
    }
    override func cancel() {
        onEvent(FlowEvent(message: "Depth \(depth) cancelled", delta: -1))
        super.cancel()
    }

    func launchNextLevel() {
        let child = FlowCoordinator(
            navigationController: navigationController,
            depth: depth + 1, maxDepth: maxDepth,
            onEvent: onEvent,                           // same closure propagates to hub
            onPerformed: { [weak self] _ in self?.pop() }
        )
        addChildAndStart(child)
    }
}
```

Each coordinator emits `delta: +1` on `start()` and `delta: -1` on `finish()`/`cancel()`. The hub accumulates the total across the entire tree regardless of nesting depth. Using `Handler<FlowEvent>` (from Common's type aliases) instead of a raw multi-parameter closure keeps call sites readable and extensible.

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

> **Production preference:** `UIButton(configuration:)` (documented in section 3) is the preferred pattern in production code — it gives full control over typography, colors, icons, and layout. `ActionButton` is available for quick prototyping and legacy screens.

Themed, rounded button:

```swift
ActionButton("Continue")                                     // Default filled theme
ActionButton("Cancel", theme: DefaultButtonTheme.border)     // Border theme
ActionButton("Submit", isEnabled: false)                     // Disabled
ActionButton("Go", shouldApplyDefaultRatio: false)           // No aspect ratio
```

Default aspect ratio: `327/40`. Built-in themes: `DefaultButtonTheme.filled`, `DefaultButtonTheme.border`. The pill corner radius (`bounds.height / 2`) is recalculated on every layout pass via a `layoutSubviews()` override — resizing the button keeps the pill shape correct. `clipsToBounds` is set to `true` eagerly at init time.

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

**Pull-to-refresh** with `UIRefreshControl.onValueChanged`:

```swift
override func setupView() {
    super.setupView()
    list.refreshControl = UIRefreshControl()
        .onValueChanged { [weak self] in
            self?.viewModel.refresh { [weak self] in
                self?.list.refreshControl?.endRefreshing()
                self?.list.reloadData()
            }
        }
}
```

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

`FieldsValidator<Field: Hashable>` is a `@MainActor`, reactive form validator shipped in Common. You declare **rules** per field (pure declarations, no values baked in), feed values with `set(_:on:)`, and receive a recomputed `State` through `onChange`. The consumer supplies its own `Field` key type (any `Hashable`). The DemoApp Forms module is a worked example.

### Setup

```swift
private enum Field: Hashable { case name, email, password, confirmPassword }

private lazy var validator = FieldsValidator<Field>(
    rules: [
        .name:            [.notEmpty, .minLength(2)],
        .email:           [.notEmpty, .email],
        .password:        [.notEmpty, .minLength(6)],
        .confirmPassword: [.notEmpty, .matches(.password)]   // cross-field
    ],
    message: { field, rule in                                // message keyed by BOTH
        switch (field, rule) {
        case (.email, .email):             "Enter a valid email address"
        case (.confirmPassword, .matches): "Passwords must match"
        default:                           rule.defaultMessage
        }
    },
    onChange: { [weak self] state in
        guard let self else { return }
        submitButton.isEnabled(state.isValid)
        state.fields.forEach { field, fieldState in
            if let message = fieldState.message { showError(field, message) }
            else { clearError(field) }
        }
    }
)
```

### Feeding values

```swift
UITextField()
    .onEditingChanged { [weak self] in self?.validator.set($0.text, on: .email) }
```

`set(nil, on:)` is treated as the empty string `""` (it does not drop the field). Each `set` fires `onChange` **exactly once**.

### Available rules

| Rule | Passes when |
|------|-------------|
| `.notEmpty` | Value is non-empty |
| `.minLength(n)` / `.maxLength(n)` | `count >= n` / `count <= n` |
| `.containsLetter` / `.containsLowercase` / `.containsUppercase` / `.containsNumber` | Contains a scalar of that class |
| `.contains(CharacterSet)` | Contains a scalar from the set |
| `.email` / `.rut` | Passes `String.isValidEmail` / `String.isRUT` |
| `.matches(Field)` / `.differs(from: Field)` | Equals / differs from another field's current value |

Every rule has a non-empty `defaultMessage`; the `message` resolver overrides per `(Field, Rule)`. A resolver returning `""` enforces validity but **suppresses display** of that rule.

### State

- `state.isValid` — `Bool`, every field satisfies every rule (ignores touched-state → use for the submit button).
- `state.fields[field]` — `FieldState` with `isValid`, `isTouched`, `errors: [Failure]`, and `message: String?` (non-empty messages joined by `"\n"`, or `nil`).
- **Touched-state is built in:** a field's `errors`/`message` stay empty until `set` is first called on it, so you never hand-roll "don't show errors until the user types." Call `touchAll()` to reveal every field's errors (e.g. on a submit attempt).

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
        // Resolve the auth token inline from an app-level Storage type. Common provides
        // `HTTPHeaders` + `.authorization(bearerToken:)`, but NOT a token-resolution protocol —
        // the token lives in your app (see §10/Storage). This mirrors production (UniPay).
        guard let token = AuthStorage().get()?.accessToken else { return .init() }
        return .init([.authorization(bearerToken: token)])
    }

    var parameters: Encodable? {
        switch self {
        case .create(let p): p
        default: nil
        }
    }
}
```

> **Note:** earlier drafts of this guide referenced an `extension Router: ResolveTokensUseCase {}`. **No such protocol exists in Common** — token resolution is done inline in `headers` as shown above, reading from an app-defined storage type.

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

### Async client (`AsyncBaseClient`)

For structured concurrency, subclass `AsyncBaseClient` instead of `BaseClient`:

```swift
final class PostClient: AsyncBaseClient {
    func fetchPosts() async throws -> [Post] {
        try await request(PostEndpoint.posts)
    }
}
```

Call sites use `async`/`await` directly:

```swift
func onViewWillAppear() {
    Task { [weak self] in
        guard let self else { return }
        do {
            let posts = try await PostClient().fetchPosts()
            view?.reload(with: posts)
        } catch {
            view?.showError(error)
        }
    }
}
```

`AsyncBaseClient` uses the same `Endpoint` router definitions as `BaseClient` — the two are interchangeable at the routing layer. Use `AsyncBaseClient` for new code where structured concurrency is available; use `BaseClient` when integrating with callback-based coordinator flows.

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
- **Two valid client styles:** (a) subclass `BaseClient` and call `request(from: #function, ...)` — adds in-flight dedup keyed by `#function`; or (b) call `HTTPService.request(router, urlSession:, result:)` directly from the client method. Production (UniPay) predominantly uses (b); the DemoApp uses (a). Pick one per client; both are supported.
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

### `UIEdgeInsets` convenience initializers

```swift
// Uniform inset on all sides
UIEdgeInsets(all: 12)                      // top: 12, left: 12, bottom: 12, right: 12

// Symmetric horizontal / vertical insets
UIEdgeInsets(horizontal: 16, vertical: 8)  // top: 8, left: 16, bottom: 8, right: 16
UIEdgeInsets(horizontal: 16)               // top: 0, left: 16, bottom: 0, right: 16
UIEdgeInsets(vertical: 8)                  // top: 8, left: 0, bottom: 8, right: 0
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
- **Don't use `alignment: .center` on a VStack/HStack that contains `UIView` spacers or plain `UIView` subviews** — `UIView` and `UIStackView` have no intrinsic width, so center-alignment collapses them to zero width and they become invisible. Use `.fill` (the default) and apply `textAlignment(.center)` on labels for visual centering. Center-alignment is safe for subviews with intrinsic content size (UILabel, UIImageView, UIButton).

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
string.trimmed   // trimmingCharacters(in: .whitespacesAndNewlines)

// Collections
array[safe: index]   // -> Element?; nil instead of out-of-bounds crash

// Logging — DEBUG only
Logger.log("some value")                          // generic item
Logger.log(request, data: data, response: resp)  // network request + response
// Logger output is compile-time gated: active in DEBUG builds, silenced in release.
// To opt in during a debug session: Logger.forceEnable()
// To get logs in a debug app that links a *Release-built* Common.xcframework
// (the default SPM artefact), flip the runtime gate at startup:
//   #if DEBUG
//   Logger.isRuntimeForceEnabled(true)
//   HTTPService.shouldLog(true)    // and any other Loggable types you care about
//   #endif
// Every settable Logger / Loggable property also has a same-named fluent setter
// (e.g. `Logger.isRuntimeForceEnabled(true).shouldLog(true)`).
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

## 17. Image Loading

Common provides a native, zero-dependency image loading subsystem under `Common/ImageLoader/`. It replaces Kingfisher / SDWebImage for the common case of loading remote images into `UIImageView`.

### Quick start

```swift
imageView.loadImage(from: url)
```

That's it — cache-first (L1 memory → L2 disk → network), placeholder, fade-in, and cancellation are all optional additions:

```swift
let options = ImageLoadOptions(
    placeholder: UIImage(systemName: "photo"),
    failureImage: UIImage(systemName: "xmark.circle"),
    transition: .fade(0.25),
    onCompletion: { result in
        switch result {
        case .success(let image): print("loaded:", image.size)
        case .failure(let error): print("failed:", error)
        }
    }
)
imageView.loadImage(from: url, options: options)
```

### Cell reuse cancellation

Call `cancelImageLoad()` in `prepareForReuse()` if you are not using `loadImage` (which auto-cancels). If you call `loadImage` again on the same view (e.g. when `viewModel` is set in `didSet`), the old task is cancelled automatically before the new one starts — no stale image can appear.

```swift
override var viewModel: MyCellViewModelProtocol? {
    didSet {
        guard let vm = viewModel else {
            thumbView.cancelImageLoad()
            return
        }
        thumbView.loadImage(from: vm.imageURL, options: .default)
    }
}
```

### ImageLoadOptions

| Property | Type | Default | Purpose |
|---|---|---|---|
| `placeholder` | `UIImage?` | `nil` | Shown synchronously while the image loads |
| `failureImage` | `UIImage?` | `nil` | Shown if the fetch throws an error |
| `transition` | `ImageTransition` | `.none` | How the image appears (`.fade(duration)`) |
| `onCompletion` | `ResultHandler<UIImage>?` | `nil` | Called on main thread with success or failure |

`ImageLoadOptions.default` sets all properties to their defaults. Pass it explicitly or omit the `options:` argument entirely.

### ImageTransition

```swift
public enum ImageTransition {
    case none               // instant assignment (used on cache hits regardless of options)
    case fade(TimeInterval) // alpha 0 → 1 animation, applied only on network-fetched results
}
```

Cache hits (L1 or L2) always use `.none` — the transition is only applied when the image came from the network.

### Cache management

```swift
// Clear all cached images (memory + disk)
await ImageLoader.shared.cache.clearAll()

// Remove one URL
ImageLoader.shared.cache.removeImage(for: url)
```

### Architecture overview

| Layer | Type | Purpose |
|---|---|---|
| `ImageCache` | `final class` | L1 `NSCache` + L2 `FileManager` disk; SHA256 URL keys; TTL + size cap |
| `ImageLoader` | `actor` | Cache-first lookup; in-flight deduplication; `@MainActor` delivery |
| `UIImageView+LoadImage` | Extension | Fluent API; per-view task cancellation via associated object |

### Supported image types

`.jpg`, `.png`, `.webp` — file extension is inferred from the `Content-Type` response header. Unknown types use `.dat` and are still decoded as `UIImage` if the data is valid.

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
- [ ] If the endpoint requires auth, resolve the token inline in `headers` from an app-level Storage type (Common has no token-resolution protocol)
- [ ] `protocol MyClientProtocol: AnyObject` with method signatures using `NetworkResultHandler<T>`
- [ ] `final class MyClient: BaseClient` (empty body)
- [ ] `extension MyClient: MyClientProtocol` with `HTTPService.request(...)` calls
- [ ] `protocol MyUseCase` + `extension MyUseCase` with default implementation
- [ ] Conform the relevant ViewController or Coordinator to `MyUseCase`
