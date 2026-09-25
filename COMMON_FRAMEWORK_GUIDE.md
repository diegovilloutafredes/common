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
18. [System Managers & Utilities](#18-system-managers--utilities)
19. [House Style](#19-house-style)
20. [Appendix A — alertView() helper](#appendix-a--alertview-helper)
21. [Appendix B — New screen checklist](#appendix-b--new-screen-checklist)
22. [Appendix C — New API domain checklist](#appendix-c--new-api-domain-checklist)

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

Both `BaseViewController` and `BaseView` expose a `mainView` property decorated with `@UIViewBuilder`. Override it to declare your view hierarchy. A view controller's `loadView()` installs it inside a plain container view that becomes `self.view`; a `BaseView` adds it as its subview, pinned edge to edge unless `mainView` declares its own constraints. Never set `self.view` directly.

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
    .borderColor(.systemGray3)
    .borderWidth(1)
    .contentType(.emailAddress)
    .font(.appFont(size: 16))
    .keyboardType(.emailAddress)
    .placeholder("Enter email", color: .systemGray3, font: .appFont(size: 16))
    .setAsRoundedView(radius: 4)
    .setRatio(327/56)
    .textColor(.label)
    .leftView(UIView(frame: .init(x: 0, y: 0, width: 16, height: 0)))   // inset; leftView(_:) also sets leftViewMode(.always)
    .isSecureTextEntry()                 // password fields; addToggleVisibilityButton() enables it too
    .autocapitalizationType(.none)
    .autocorrectionType(.no)
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
- `loadView()` installs `mainView` inside a plain container view, which becomes `self.view`: `view !== mainView`, and `$1` in `mainView`'s `setConstraints` is that container
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
    private lazy var list = VList(dataSource: self, delegate: self)
        .register(ProductCell.self)
        .setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }

    @UIViewBuilder
    override var mainView: UIView { list }
}
```

The base class accesses the ViewModel via `viewModel as? CollectionViewable` at runtime — the generic constraint on `ViewModelType` is intentionally absent because Swift's existential type system prevents protocol types from satisfying generic protocol constraints.

Override `bottomInsetForLastCollectionSection()` when the screen sits above a tab bar (default returns `.zero`).

**The cell contract.** `CollectionViewable` is `CollectionViewDataSourceable & CollectionViewDelegateable & CollectionViewSizeable`; the base VC forwards every `UICollectionView` callback to these hooks, so the ViewModel — not the VC — answers them. Three are required, one of the two sizing hooks must be implemented, and the rest have defaults:

```swift
@MainActor
final class ProductsViewModel {
    private var products: [ProductCellViewModel] = []
}

extension ProductsViewModel: CollectionViewable {
    func getNumberOfSections() -> Int { 1 }                                                  // default 1
    func getNumberOfItems(in section: Int) -> Int { products.count }                         // required
    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { ProductCell.reuseIdentifier } // required
    func onCellForItem(in section: Int, at index: Int) -> ViewModel? { products[index] }     // required — assigned to cell.viewModel
    func onSizeForItem(in section: Int, at index: Int, availableSize: Size) -> Size { (availableSize.width, 68) } // implement this one
    func onItemSelected(in section: Int, at index: Int) { select(products[index]) }         // default no-op
    func onInsetFor(section: Int) -> Inset { (top: 4, left: 0, bottom: 8, right: 0) }        // default zero
    func onMinimumLineSpacingFor(section: Int) -> Double { 4 }                               // default zero (also onMinimumInteritemSpacingFor)
}
```

**Sizing.** The base controller hands the ViewModel `availableSize`: the list's bounds inset by its adjusted content inset and by this section's inset (including `bottomInsetForLastCollectionSection()`), clamped at zero. Full-width rows return `availableSize.width`; a paged `HList` returns `availableSize` whole; no ViewModel reads `screenWidth` through a view reference. The legacy `onSizeForItem(in:at:)` still exists: the `availableSize` hook forwards to it by default and it defaults to `(.zero, .zero)`, so a ViewModel implements **exactly one** — implementing neither (or mistyping a label so neither matches) renders an empty list with no error, the same failure mode as a ViewModel that does not conform to `CollectionViewable` at all. Cells self-register their reuse identifier (`static var reuseIdentifier` on every `UICollectionReusableView` = the type name). Never hand-roll `UICollectionViewDataSource` in the VC: the base class already owns it.

**Section headers and footers.** Register the supplementary view with `.register(_:kind:)` and have the ViewModel answer the three hooks per kind — reuse identifier, view model, size (the size hooks take `availableSize` like items do, section inset subtracted). A flow layout doesn't inset headers and footers: it uses only the size along the scrolling direction and stretches the view across the list, so a header that measures its height against its real width adds the section's left and right insets back to `availableSize.width`. The size defaults to `(.zero, .zero)`, which means "no header/footer in this section"; a non-zero size **requires** a matching reuse identifier, or UIKit throws on dequeue.

```swift
private lazy var list = VList(dataSource: self, delegate: self)
    .register(ProductCell.self)
    .register(SectionHeaderView.self, kind: .header)
    .register(SectionFooterView.self, kind: .footer)

// ViewModel (CollectionViewable) — header in every section, footer under the last one only
func onHeaderItemReuseIdentifierRequested(in section: Int) -> String { SectionHeaderView.reuseIdentifier }
func onHeaderItemDataSourceRequested(in section: Int) -> ViewModel? { sections[section].headerViewModel }
func onSizeForHeaderItem(in section: Int, availableSize: Size) -> Size { (availableSize.width, 36) }

func onFooterItemReuseIdentifierRequested(in section: Int) -> String { SectionFooterView.reuseIdentifier }
func onFooterItemDataSourceRequested(in section: Int) -> ViewModel? { section == lastSection ? footerViewModel : nil }
func onSizeForFooterItem(in section: Int, availableSize: Size) -> Size { section == lastSection ? (availableSize.width, 32) : (.zero, .zero) }
```

Supplementary views subclass `BaseViewModelableReusableView<T>` and bind in `updateContent()`, exactly like cells (the same view may be registered for both kinds). `Size` and `Inset` are labeled tuples (`(width:height:)`, `(top:left:bottom:right:)`).

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

For collection/table view cells, bind content in `updateContent()` — `mainView` is built once in `init` and the `viewModel` property is `nil` at that point. Assigning `viewModel` runs `updateContent()` **synchronously** (self-sizing cells are measured right after configuration, so the content must already be there), and if the model is `@Observable` any later change to a property read inside re-runs it on the next pass:

```swift
// Protocol — defines what the cell reads
protocol ListItemCellViewModel: ViewModel {
    var title: String { get }
    var subtitle: String { get }
    var accentColor: UIColor { get }
}

// Cell — layout in mainView, content in updateContent()
final class ListItemCell: BaseViewModelableCell<ListItemCellViewModel> {
    private lazy var titleLabel = UILabel().font(.boldSystemFont(ofSize: 15)).textColor(.label)
    private lazy var subtitleLabel = UILabel().font(.systemFont(ofSize: 12)).textColor(.secondaryLabel)

    @UIViewBuilder override var mainView: UIView {
        VStack(spacing: 2) { titleLabel; subtitleLabel }
            .setConstraints { $0.snap(to: $1) }
    }

    override func setupCell() {
        super.setupCell()
        backgroundColor(.clear)
    }

    override func updateContent() {
        guard let viewModel else { return }
        titleLabel.text(viewModel.title)
        subtitleLabel.text(viewModel.subtitle)
    }
}
```

> **Critical**: Never reference `viewModel` inside `mainView` — it is `nil` when the view builder runs. All model-driven updates go in `updateContent()`.

`override var viewModel { didSet { … } }` still works for plain value models and runs synchronously on assignment; prefer `updateContent()` for new code so the cell has one render path. Work that must happen exactly once per assignment (e.g. issuing an image load) belongs behind a guard on the bound value, because `updateContent()` may run more than once — see `ImageDemoCell` in the DemoApp.

### Lifecycle hooks

Lifecycle work goes through hooks instead of overrides, and the two sides share names:
- **Logic** (loading data, starting a session) goes in the ViewModel's `ViewLifecycleable` methods, which the base view controller calls: `onViewDidLoad()`, `onViewWillAppear()`, `onViewIsAppearing()`, `onViewDidAppear()`, `onViewWillLayoutSubviews()`, `onViewDidLayoutSubviews()`, `onViewWillDisappear()`, `onViewDidDisappear()`, and the legacy `onUpdateProperties()`.
- **View-only work** (bar visibility) uses the closures every view controller has. Set them in `setupView()`, or from the coordinator on the instance it creates (§7):

| Closure | When it fires |
|------|--------------|
| `onViewDidLoad { vc in ... }` | Before `setupView()`, so register it from outside (the coordinator); one registered in `setupView()` never fires |
| `onViewWillAppear { vc in ... }` | Before every appearance |
| `onViewIsAppearing { vc in ... }` | Every appearance, once the view is in the hierarchy with its final size and traits |
| `onViewDidAppear { vc in ... }` | After every appearance |
| `onViewWillDisappear { vc in ... }` | Before the view disappears |
| `onViewDidDisappear { vc in ... }` | After the view disappears |

A closure runs before the ViewModel's method of the same name. For layout passes, the hook is on the view: `view.onLayoutSubviews { view in ... }`.

```swift
override func setupView() {
    super.setupView()
    onViewWillAppear { $0.hideNavigationBar(animated: false) }
    onViewWillDisappear { $0.showNavigationBar(animated: false) }
}

// In the ViewModel, not the view controller:
func onViewIsAppearing() { load() }
```

### Observation-driven updates

Read `@Observable` state in **one** hook and let the framework re-run it. No `didSet`, no `setNeedsLayout`, no rebuild closures.

| Where | Hook | Trigger |
|---|---|---|
| `BaseViewController` subclass | `updateContent()` | first pass, then any tracked change |
| `BaseView`, `BaseCell`, `BaseReusableView` subclasses | `updateContent()` | same; view-model-able variants bind synchronously on `viewModel` assignment (`updateContentIfNeeded()`) |
| Anywhere | `setNeedsContentUpdate()` | forces a re-run on the next pass |
| ViewModel (`ViewLifecycleable`) | `onUpdateProperties()` | same pass as the controller's hook — an escape hatch, see below |

```swift
@Observable @MainActor final class ProfileViewModel: ViewModel {
    private(set) var name = ""
    private(set) var canSave = false
    private(set) var event: ViewEvent<Event>?     // one-shot effects are state too
    enum Event { case saved }
}

final class ProfileViewController: BaseViewModelableViewController<ProfileViewModel> {
    private var eventCursor = ViewEventCursor()
    override func updateContent() {
        super.updateContent()
        nameLabel.text(viewModel.name)            // tracked reads
        saveButton.isEnabled(viewModel.canSave)
        eventCursor.consume(viewModel.event) { _ in Snackbar.show(.init(message: "Saved")) }   // once per firing
    }
}

final class ProfileCell: BaseViewModelableCell<ProfileModel> {
    override func updateContent() {
        guard let viewModel else { return }
        nameLabel.text(viewModel.name)          // re-runs when name changes
    }
}
```

**Mechanism per OS** (`ObservationMode.current`):

| Runtime | Mode | How |
|---|---|---|
| iOS 26+ | `.native` | UIKit's `updateProperties()` — runs before layout; text/color changes cost no layout pass |
| iOS 17–18 | `.manual` | Common wraps the hook in `withObservationTracking` from `layoutSubviews` / `viewWillLayoutSubviews` and re-arms on the next pass; no Info.plist key needed. On iOS 18 with `UIObservationTrackingEnabled` set, UIKit also tracks the same reads: both invalidate (UIKit synchronously, Common on the next main-actor hop), which can cost a second layout pass per change but stays correct because the hook is idempotent |
| iOS 16 | `.unavailable` | the hook runs on every layout pass, untracked |

Rules:
- Read state and write views inside the hook only. Mutate models anywhere on the main actor except inside the hook: in manual mode (iOS 17–18) a write there to state the same pass reads is lost. It lands before the pass arms its observer, so the hook doesn't re-run and the view keeps the value it read before the write. Move such writes to `onViewWillAppear()` or a `Task`. Native mode isn't verified to behave differently, so treat both modes the same.
- Constraint constants may be written in the hook; the layout pass that follows applies them. To animate one, mutate the state inside the animation block: `animateConstraints { viewModel.toggle() }` on iOS 17–18 (its `layoutIfNeeded()` runs the hook inside the block) or `UIView.animate(withDuration:delay:options: .flushUpdates) { viewModel.toggle() }` on iOS 26. Geometry *derived* from layout (a list's content height) only exists after layout — sync it in `viewDidLayoutSubviews()` (or after `super.layoutSubviews()` in a view), not in the hook.
- The hook may run more than once per change; make it idempotent.
- Do not call `updateContent()` / `updateProperties()` yourself — call `setNeedsContentUpdate()`.
- Always call `super.updateContent()` first in a controller override: the base forwards to the view model's `onUpdateProperties()`.
- **Events are state with identity.** Text, flags, counts and collections are plain observed state. One-shot effects (a snackbar, an error alert, "submitted") go through a `ViewEvent<Payload>?` slot on the ViewModel: assigning `.init(payload)` gives the firing a fresh `UUID`, so the controller's `ViewEventCursor` (`consume(_:_:)` in the hook) acts once per firing however many times the hook re-runs, and never writes ViewModel state to do so. Ceilings: the slot is last-writer-wins between two passes (screens that can burst keep an array behind a `revision`). A controller covered by a push or a full-screen presentation leaves the window and consumes a pending event when it returns on screen. One covered by a sheet (`.pageSheet`, `.formSheet`) or an `.overFullScreen` presentation stays in the window, so its hook keeps running and consumes the event underneath. There, a handler that calls the controller's own `present(_:animated:)` fails, because the controller is already presenting, and the event is spent. `presentAlertView` (presented from the top-most controller) and `Snackbar` (added to the key window) still show. A modal effect over the current screen is an event the controller presents; anything that starts a module or flow is an `onRequested` case the coordinator answers (§6).
- **`onUpdateProperties()` is an escape hatch.** The ViewModel-side hook runs in the same pass and tracks the same way, but it needs somewhere to push into — a view reference the module contract no longer has. Keep it for code written against earlier releases; new modules render in the controller's `updateContent()` only.
- **Observation fires on every assignment, not on every change.** Guard setters that run often (`scrollViewDidScroll`, frame counters): `guard currentPage != new else { return }`, and throttle before the observable write.
- **Collections go behind a `revision`.** Keep the array `@ObservationIgnored`, bump a tracked `revision: Int` when it changes, and let the controller compare it with the revision it last rendered before calling `reloadData()`. This keeps status-only changes from reloading, and on iOS 26 it avoids a second dependency: `UICollectionView.layoutSubviews()` is itself tracked, so data-source callbacks reading a tracked array would also invalidate the collection view.
- Loading indicators: mirror an `isLoading` flag with `setActivityIndicator(visible:)` — idempotent, so it is safe on every pass.
- A controller whose view is off-window (pushed over) does not re-render while covered; it renders once on return. Expected.
- Self-sizing cells (`estimatedItemSize = .automaticSize`, `preferredLayoutAttributesFitting`) are measured before any update or layout pass. That is why `viewModel` assignment binds synchronously; if you bind from anywhere else before a measurement, call `updateContentIfNeeded()` first.
- Self-sizing rows are estimated at the width `onSizeForItem` returns. Return `availableSize.width` — the list's own width, handed in by the base controller — never `screenWidth`: an inset list (card margins) rejects items wider than itself and renders nothing.

Migration recipe (what the DemoApp modules went through):

```swift
import Observation                                   // UIKit does not re-export it

@Observable @MainActor                               // @MainActor VM ⇒ @MainActor wireframe factory
final class FooViewModel: FooViewModelProtocol {     // the protocol is @MainActor too
    private(set) var statusText = ""                 // state: tracked
    private(set) var isLoading = false
    private(set) var revision: Int = .zero           // collections: revision, not the array
    @ObservationIgnored private var items: [Item] = [] { didSet { revision += 1 } }
    private(set) var event: ViewEvent<Event>?                    // one-shot effects: a fresh value per firing
    @ObservationIgnored private let onRequested: Handler<Requested>   // lazy/closures: ignored
    @ObservationIgnored private lazy var validator = …
}

final class FooViewController: BaseViewModelableViewController<FooViewModelProtocol> {
    private var renderedRevision: Int = .zero
    private var eventCursor = ViewEventCursor()
    override func updateContent() {
        super.updateContent()
        statusLabel.text(viewModel.statusText)
        setActivityIndicator(visible: viewModel.isLoading)
        if renderedRevision != viewModel.revision { renderedRevision = viewModel.revision; list.reloadData() }
        eventCursor.consume(viewModel.event) { [weak self] in self?.handle($0) }
    }
}
```

Every DemoApp module is written this way; the **Observation** module additionally shows a *Collections behind a revision* card (adding or removing a row reloads through the tracked `revision`, while a row tap re-runs only that cell), a *Constraints from state* card (a width constant written in the hook, animated per the rule above) and a *State vs events* card where one tap both mutates observed state (rendered in the hook) and fires a `ViewEvent` the same hook consumes once through its cursor.

### System notification observers

```swift
observe(.onDidBecomeActive)    { [weak self] in guard let self else { return }; resume() }
observe(.onDidBecomeIdle)      { [weak self] in guard let self else { return }; pauseWork() }
observe(.onWillResignActive)   { [weak self] in guard let self else { return }; saveState() }
observe(.onSceneDidDisconnect) { [weak self] in guard let self else { return }; cleanup() }
```

### Activity indicators

Under the module contract, mirror the ViewModel's loading flag in `updateContent()`. `setActivityIndicator(visible:)` starts or stops only when the flag changes, so it's safe on every pass:

```swift
override func updateContent() {
    super.updateContent()
    setActivityIndicator(visible: viewModel.isLoading)
}
```

Imperative code pairs `startActivityIndicator()` (or `startActivityIndicator(with: color)`) with `stopActivityIndicator()`, including on failure paths. Neither takes a message or a completion closure.

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

Observed at runtime for a `BaseViewModelableViewController` pushed in a navigation controller. In every step that has hooks, the view controller's closure (`onViewWillAppear { }` and the rest) runs first, inside `super`, and then the ViewModel's `ViewLifecycleable` method.

1. `init(viewModel:)` — the ViewModel is injected.
2. `loadView()` — reads `mainView` once and installs it in a plain container view, which becomes `self.view` (`view !== mainView`).
3. `viewDidLoad()` — the `onViewDidLoad` closure, then `setupView()`, then the ViewModel's `onViewDidLoad()`. An `onViewDidLoad` closure registered inside `setupView()` never fires: that point has passed.
4. `viewWillAppear(_:)` — the swipe-to-go-back gesture is re-enabled.
5. `updateContent()`, the first render. In native mode (iOS 26+) it runs from `updateProperties()`, here. In manual mode (iOS 17–18) it runs at the start of the first `viewWillLayoutSubviews()`, step 7. The ViewModel's legacy `onUpdateProperties()` runs inside it, at `super.updateContent()`.
6. `viewIsAppearing(_:)` — the view is in the hierarchy; size and traits are final.
7. `viewWillLayoutSubviews()`, then `viewDidLayoutSubviews()`.
8. `viewDidAppear(_:)`.
9. When another screen covers it or it is removed: `viewWillDisappear(_:)`, then `viewDidDisappear(_:)`.

Every later appearance (returning from a pushed screen, for example) runs steps 4, 6 and 8 again, so `onViewIsAppearing` fires on each appearance, not only the first. A change to observed state re-runs only `updateContent()`: from `updateProperties()` in native mode, from a layout pass in manual mode.

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
```

> **Main-thread delivery:** use `Task { @MainActor in ... }`, not the legacy
> `dispatchOnMain` / `dispatchOnMainAfter` helpers. Those are `DispatchQueue`-backed,
> and under Xcode 26's concurrency runtime `DispatchQueue.main` is a separate
> scheduler from `@MainActor` — callbacks delivered through it silently fail to
> fire in async test contexts (`await fulfillment(of:)`).

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
├── ModuleNameViewController.swift   — UI (mainView + setupView + updateContent)
├── ModuleNameViewModel.swift        — Observable state + intents + use cases + output closures
└── ModuleNameWireframe.swift        — Factory that wires VC + VM
```

### The module contract

Data flows one way. Nothing on the ViewModel points back at its controller or its coordinator.

| Direction | Mechanism |
|---|---|
| Controller → ViewModel | Method calls (intents: `viewModel.save()`, `viewModel.goBack()`) and the `ViewLifecycleable` hooks |
| ViewModel → Controller, state | `@Observable` properties, read in `updateContent()`; the framework re-runs it on change (§5 *Observation-driven updates*) |
| ViewModel → Controller, one-shot effects | A `ViewEvent` slot — still observed state, consumed once by the controller's `ViewEventCursor` (§5) |
| ViewModel → Coordinator | Two constructor-injected closures: `onRequested` (navigation to answer) and `onPerformed` (results to react to) |
| Coordinator → ViewModel | Constructor arguments, or writes into it as a data source (a coordinator may keep a `weak` ViewModel to feed it) |

No `weak var view`, no `weak var delegate`. Measurements the ViewModel used to read through a view protocol (a list's width) are handed in by the framework instead (`availableSize`, §5).

### Wireframe implementation

```swift
enum ProfileWireframe {
    @MainActor static func createModule(
        onRequested: @escaping Handler<ProfileViewModel.Requested>,
        onPerformed: @escaping Handler<ProfileViewModel.Performed>
    ) -> UIViewController {
        ProfileViewController(viewModel: ProfileViewModel(onRequested: onRequested, onPerformed: onPerformed))
    }
}
```

- **Enum** (not struct/class) — purely a namespace, no state
- **`createModule`** is the single factory entry point; it takes only the output closures the module has (most screens only request; a screen with no outputs takes nothing)
- No back-reference is wired after init

### ViewModel pattern

```swift
import Observation

@Observable @MainActor
final class ProfileViewModel: ViewModel {
    /// Navigation the coordinator answers.
    enum Requested { case goBack, editProfile }
    /// Results the coordinator reacts to.
    enum Performed { case loggedOut }
    /// Modal effects over this screen; the controller presents them.
    enum Event { case saved, failed(message: String) }

    private(set) var name = ""                                   // state: tracked, rendered by the controller
    private(set) var event: ViewEvent<Event>?                    // one-shot effects: tracked, consumed once
    @ObservationIgnored private let onRequested: Handler<Requested>
    @ObservationIgnored private let onPerformed: Handler<Performed>

    init(onRequested: @escaping Handler<Requested>, onPerformed: @escaping Handler<Performed>) {
        self.onRequested = onRequested
        self.onPerformed = onPerformed
    }

    func goBack() { onRequested(.goBack) }                       // the controller's back button calls this
    func editProfile() { onRequested(.editProfile) }
    func load() { name = "Ada" }                                 // mutate state; the controller re-renders
    func save() { event = .init(.saved) }                        // fire an effect; the controller presents it once
    func logout() { onPerformed(.loggedOut) }
}

final class ProfileViewController: BaseViewModelableViewController<ProfileViewModel> {
    private var eventCursor = ViewEventCursor()

    override func setupView() {
        super.setupView()
        addBackButton { [weak self] in self?.viewModel.goBack() }
    }

    override func updateContent() {
        super.updateContent()
        nameLabel.text(viewModel.name)                           // tracked read
        eventCursor.consume(viewModel.event) { event in          // once per firing
            switch event {
            case .saved: Snackbar.show(.init(message: "Saved"))
            case .failed(let message): Snackbar.show(.init(message: message))
            }
        }
    }
}
```

- State (text, flags, counts, a collection `revision`) lives on the `@Observable` ViewModel and is read in `updateContent()` — no `didSet`, no `set(title:)`-style view calls
- Closures and `lazy` properties are `@ObservationIgnored`; `let` constants are never tracked
- The controller reaches the output closures only through intents (`viewModel.goBack()`), never directly
- `Requested` / `Performed` / `Event` are nested in the ViewModel; declare only the ones the module has

### Requested, Performed, Event — which is which

| Kind | Fires | Handled by | Examples |
|---|---|---|---|
| `Requested` | many times | coordinator, with navigation | go back, open detail, present a sheet built by a wireframe, start a child flow |
| `Performed` | once per unit of work | coordinator, reacting to a result | logged in, onboarding completed, payment sent |
| `Event` | as often as it happens | controller, presenting over the current screen | alert, snackbar, toast, action sheet, "submitted" |

The line between `Event` and `Requested`: a modal effect **over this screen** is an event the controller presents; anything that **starts a module or flow** is a request the coordinator answers. The same pair exists one level up — `BaseCoordinator` takes `onPerformed` and fires it from `finish()` — so module → coordinator and child → parent read alike.

### Screens without a ViewModel

Static screens skip the ViewModel and the wireframe: a `BaseViewController` subclass takes the same closures in its `init` and the coordinator wires them directly.

```swift
final class SheetFlowViewController: BaseViewController {
    enum Requested { case dismiss, swap }
    private let onRequested: Handler<Requested>

    init(onRequested: @escaping Handler<Requested>) {
        self.onRequested = onRequested
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}
```

Use the full VC + VM + wireframe set when there is real view-model state to hold; don't add empty ceremony for a static screen. Never add closures to a `BaseViewModelableViewController` subclass: it would force a stubbed `required init(viewModel:)`. Closures belong on the ViewModel.

### `BaseModuleDelegate` (legacy)

Earlier releases wired navigation through `weak var delegate: BaseModuleDelegate?` (`GoBackRequestable`, `DismissRequestable`, `AlertRequestable`, `ActivityControllerRequestable`), which `BaseCoordinator` still implements with default behavior (`onGoBackRequested()` → `pop()`, `onDismissRequested()` → `dismiss()`). The typealias and the conformance stay for compatibility; new modules use `onRequested` instead, and the DemoApp no longer uses the delegate anywhere.

### Do's and Don'ts

- **Do** use an `enum` for wireframes — stateless factories only.
- **Do** keep the ViewModel free of `view`, `delegate` and coordinator references.
- **Do** mark `init?(coder:)` as `@available(*, unavailable)` on `BaseViewController` subclasses that declare an `init`.
- **Don't** put business logic in the wireframe — it only wires dependencies.
- **Don't** let view controllers navigate directly — they call a ViewModel intent that fires `onRequested`.
- **Don't** declare an initializer in a `BaseViewModelableViewController` subclass — `init(viewModel:)` is inherited.

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
        push(HomeWireframe.createModule { [weak self] request in
            guard let self else { return }
            switch request {
            case .settings: push(SettingsWireframe.createModule())
            case .checkout: addChildAndStart(CheckoutCoordinator(navigationController: navigationController))
            }
        })
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

Start/stop is state-preserving: a `UITextField` gets its previous `rightView`/`rightViewMode` back on stop (e.g. a password-toggle button survives a spinner cycle), and a `UIView` restores only the subviews that were visible before start — subviews hidden intentionally stay hidden.

#### `AlertPresentable`

```swift
presentAlertView(type: .genericError, acceptAction: nil, cancelAction: nil)
presentAlertView(type: .customAlert(title: "Oops", message: "Something failed"), acceptAction: { _ in }, cancelAction: nil)
```

### Child coordinators

`addChildAndStart` stores the child, calls `start()`, and tracks the first screen the child pushes. When that screen leaves the navigation stack (back button, swipe-back, a pop, or a replaced stack), UIKit's view-controller containment callback (`didMove(toParent:)`) cancels the child, which removes it from `childCoordinators`. `finish()` removes it too, so no manual `removeChild` call is needed in `onPerformed`. The `onPerformed` closure is for the parent to react to the result (e.g. pop a screen, show the next one):

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

### Swipe-back and back-button cancellation

**Nothing to wire on the parent's stack.** A coordinator started with `addChildAndStart` cancels itself when its entry screen leaves the navigation stack — back button, swipe-back, `pop()`, `pop(.to(viewController:))`, `pop(.toRoot)`, or a stack replacement. `BaseCoordinator` tracks the screen through UIKit's view-controller containment callback, so no ViewController code participates.

**A flow presented in its own navigation controller is the exception.** Its screens never land on the parent's stack, and dismissing the presented controller doesn't remove them from their container, so nothing cancels the flow. Wire both endings: the child cancels itself when the sheet is swiped down, and the parent closes the sheet when the child finishes.

```swift
extension SettingsCoordinator: UIAdaptivePresentationControllerDelegate {
    // Swipe-down: the sheet is already gone, so abandon the flow. (Not called for a programmatic dismiss.)
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) { cancel() }
}

// In the parent coordinator:
func presentSettings() {
    let sheet = UINavigationController()
    let flow = SettingsCoordinator(
        navigationController: sheet,
        onPerformed: { [weak self] _ in self?.dismiss() }   // the flow finished: the parent closes the sheet
    )
    addChild(flow)                                  // not addChildAndStart: nothing lands on this stack to track
    flow.start()                                    // the flow sets its first screen into `sheet`
    sheet.presentationController?.delegate = flow   // set before presenting
    present(.overCurrent, viewController: sheet)    // the default, .dismissingCurrent, closes what's on screen first
}
```

Either ending removes the child from `childCoordinators`.

Override `cancel()` when the flow needs to react to abandonment:

```swift
final class CheckoutCoordinator: BaseCoordinator {
    override func cancel() {
        analytics.log("checkout_abandoned")
        super.cancel()   // always call super — it performs the teardown
    }
}
```

If a **ViewController** needs its own reaction to being popped (stopping a camera session, invalidating a timer), use the lifecycle hook — but don't call `cancel()` from it; the coordinator has already handled itself:

```swift
onViewWillDisappear { [weak self] _ in
    guard let self, isMovingFromParent else { return }
    stopCameraSession()
}
```

> Popping past several child coordinators at once (`pop(.to(_:))`, `pop(.toRoot)`) cancels **each** of them.

### Modules never see the coordinator

A ViewModel or wireframe never depends on a coordinator — not the class, not a protocol for it. The module declares what it can ask for (`Requested`) and what it reports (`Performed`), and the coordinator that builds it supplies the closures. Modules stay independently testable (capture the closures in a test) and there are no import cycles:

```swift
// The module declares its outputs
@Observable @MainActor
final class CheckoutViewModel: ViewModel {
    enum Requested { case showConfirmation(Order) }
    enum Performed { case failed(Error) }
    …
}

enum CheckoutWireframe {
    @MainActor static func createModule(
        onRequested: @escaping Handler<CheckoutViewModel.Requested>,
        onPerformed: @escaping Handler<CheckoutViewModel.Performed>
    ) -> UIViewController {
        CheckoutViewController(viewModel: CheckoutViewModel(onRequested: onRequested, onPerformed: onPerformed))
    }
}

// The coordinator answers
final class CheckoutCoordinator: BaseCoordinator {
    override func start() {
        push(CheckoutWireframe.createModule(
            onRequested: { [weak self] request in
                switch request {
                case .showConfirmation(let order): self?.push(ConfirmationWireframe.createModule(order: order))
                }
            },
            onPerformed: { [weak self] result in
                switch result {
                case .failed: self?.finish()   // not cancel(): that leaves this flow's screens on the stack; the parent unwinds them in onPerformed
                }
            }
        ))
    }
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
        .onViewDidAppear { [weak self] _ in
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(0.3))
                guard let self else { return }
                set(initialViewController, animated: true)
            }
        }
        .onViewWillDisappear { $0.showNavigationBar(animated: false) }
}
```

### Where use cases live

Use-case protocols are conformed by the **ViewModel**. A network result is state of a screen, so it lands in that screen's observable ViewModel and the controller renders it; the coordinator never has to reach into a controller it does not own to deliver it, and the logic is testable without a navigation controller.

```swift
extension CheckoutViewModel: FetchCartUseCase {}
extension CheckoutViewModel: SubmitOrderUseCase {}
```

A coordinator conforms only for an app-level flow no screen owns — logout, session refresh, deep-link resolution on the root coordinator — and even there a small flow object is preferable. View controllers never conform.

```swift
extension AppCoordinator: LogoutUseCase {}   // app-level, no screen owns it
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

### Default delegate behavior (legacy)

`BaseCoordinator` still conforms to `BaseModuleDelegate` for modules written against earlier releases: `onGoBackRequested()` → `pop()`, `onDismissRequested()` → `dismiss()`. New modules fire `onRequested(.goBack)` and the coordinator pops (§6).

### Do's and Don'ts

- **Do** end a child flow with `finish()` and let the parent unwind its screens in `onPerformed`. Removal from `childCoordinators` is automatic (on `finish()`, and on `cancel()` when the entry screen leaves the stack), so don't call `removeChild` yourself. A flow presented modally is the exception: wire its interactive dismissal as shown in *Swipe-back and back-button cancellation*.
- **Do** use computed vars for VC properties — avoids stale state.
- **Don't** present or push directly from a ViewController — route through the coordinator. The exception is a modal effect over the current screen (alert, snackbar): that is a `ViewEvent` the controller presents itself (§6).
- **Don't** hold strong references to child coordinators outside `childCoordinators`.
- **Don't** conform coordinators to use cases for screen work — the screen's ViewModel owns it (*Where use cases live*).

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

// addSeparator RETURNS a new VStack wrapping the view + separator — use the
// return value. Discarding it reparents the view and displays nothing.
let labelWithSeparator = myLabel.addSeparator(color: .gray, height: 1)
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
`onDismiss` always fires exactly once, even when no window is available to
present in (the snackbar then never appears). Only the visible card intercepts
touches — the transparent strips beside it pass through to the UI beneath —
and the auto-dismiss timer keeps counting while the user scrolls.

### `Toast`

```swift
Toast.present(with: "Saved", duration: .short)   // .short (1s), .medium (3s), .long (5s)

Toast.present(with: "Uploaded") { /* runs once the toast is gone */ }
```

A toast is purely informational: its whole hierarchy is touch-transparent and
never blocks the UI beneath it. Only one toast is shown at a time — a new
`present` replaces the current one (firing its completion at replacement).
The completion is always delivered exactly once, including when no host view
is available.

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

Cells subclass `BaseViewModelableCell<T>` and use `@UIViewBuilder` for layout. Always call `.register(CellType.self)` before use — and `.register(View.self, kind: .header)` / `.footer` for supplementary views (see §5, "Section headers and footers").

**Pull-to-refresh** with `UIRefreshControl.onValueChanged`. The gesture calls an intent; the ViewModel tracks `isRefreshing` and bumps `revision` when the items change; the controller mirrors both in `updateContent()` (this is what the DemoApp's Lists module does):

```swift
override func setupView() {
    super.setupView()
    list.refreshControl = UIRefreshControl()
        .onValueChanged { [weak self] in self?.viewModel.refresh() }
}

override func updateContent() {
    super.updateContent()
    if renderedRevision != viewModel.revision { renderedRevision = viewModel.revision; list.reloadData() }
    if !viewModel.isRefreshing, list.refreshControl?.isRefreshing == true { list.refreshControl?.endRefreshing() }
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

### `ProgressAnimationView`

Determinate gradient progress sweep with a completion callback:

```swift
private lazy var progressView = ProgressAnimationView()
    .backgroundColor(.systemGray5)
    .round(radius: 8)
    .setConstraints { $0.set(height: 16) }

progressView.animate(
    progressColor: UIColor.systemGreen.cgColor,
    backgroundColor: UIColor.systemGray5.cgColor,
    duration: 1.5
) { [weak self] in self?.onProgressFinished() }
```

The completion fires exactly once per `animate` call — including when the
animation is interrupted (backgrounding, window removal); a newer `animate`
call supersedes the previous one.

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

Animations survive backgrounding and window transitions: Core Animation strips
them, and the view re-adds them automatically while `isAnimating` is `true`
(re-adding resets the phase — meaningless for an indeterminate spinner). An
explicitly stopped indicator stays stopped.

### More components — one-liners

```swift
// GradientView — CAGradientLayer-backed; colors re-resolve on dark/light flips
GradientView().colors(startColor: .systemBlue, endColor: .systemTeal).horizontalMode()
GradientView().colors(startColor: .black, endColor: .clear).endLocation(0.6)
    .with { $0.diagonalMode = true }   // diagonal: top-left → bottom-right; + horizontalMode: top-right → bottom-left. startLocation is settable too.

// PillUILabel — pill-shaped label; padding honored in measurement AND drawing
PillUILabel().text("NEW").font(.systemFont(ofSize: 12, weight: .bold))

// PreviewView — AVCaptureVideoPreviewLayer-backed camera preview (see CameraManager, §18)
PreviewView().videoGravity(.resizeAspectFill)

// DNITextField — Chilean DNI/RUT entry field with built-in formatting
DNITextField()
```

### Base classes summary

| Class | Extends | Purpose |
|-------|---------|---------|
| `BaseView` | `UIView` | Custom views with `mainView` pattern |
| `BaseButton` | `UIButton` | Custom buttons with `setupView()` hook |
| `BaseLabel` | `UILabel` | Custom labels with `setupView()` hook |
| `BaseTextField` | `UITextField` | Custom text fields with `setupView()` hook |

All base classes: disable `NSCoder` init, set `requiresConstraintBasedLayout = true`, provide `setupView()` hook.

### PaddingLabel

A `UILabel` that insets its text by a configurable `UIEdgeInsets` — for chips, tags, and badges. The padding is reflected in `intrinsicContentSize`, and wrapped multi-line text stays within the horizontal insets (it overrides `textRect(forBounds:limitedToNumberOfLines:)`, so padding is applied once, not double-counted).

```swift
PaddingLabel(padding: .init(all: 4))
    .text(tagTitle)
    .font(.appFont(style: .bold, size: 10))
    .backgroundColor(.systemPink.withAlphaComponent(0.2))
    .setAsRoundedView(radius: 4)
```

`padding` defaults to `.zero`, in which case it behaves like a plain `UILabel`. The padding is physical: `left` and `right` are not mirrored in right-to-left layouts. Its first baseline includes the top padding, so a `firstBaselineAnchor` constraint lines up the text itself, with the label's frame `padding.top` higher than a plain label's.

### GIFImageView

A `UIImageView` that plays animated GIFs with ImageIO. Frames are decoded one at a time on a `CADisplayLink` as they are shown, so memory stays flat regardless of the GIF's frame count. Playback pauses automatically while the view is not in a window and resumes when it joins one; an explicit `stopAnimating()` stays stopped until `startAnimating()`.

```swift
let gif = GIFImageView()
gif.loadGIF(named: "spinner")                     // "spinner.gif" in the main bundle
gif.loadGIF(named: "logo", in: brandAssetsBundle) // any other bundle
gif.loadGIF(from: data)                           // raw GIF data
```

Notes:
- `loadGIF(named:in:)` resolves `<name>.gif` in `bundle` (default `.main`); a missing resource is ignored and the view is left unchanged. (A diagnostic is logged only in debug builds of the framework source — the release binary is silent.)
- Undecodable data is also ignored — a GIF that is already playing keeps playing.
- Assigning `image` directly stops GIF playback and clears the loaded GIF, so the assigned image sticks.
- Playback advances by wall time — dropped display-link ticks catch up by skipping frames — and a single-frame GIF is shown as a static image (no display link).
- Each frame is decoded on the **main thread** as it is displayed — inexpensive for typical UI GIFs, but a very large GIF can hitch. Memory stays flat (`kCGImageSourceShouldCache = false`).
- Per-frame durations come from the GIF metadata; delays below `0.02s` are normalized to `0.1s`.
- The GIF's loop-count metadata is **not** honored — playback loops until `stopAnimating()` or an `image` assignment.
- `isPlayingGIF` is `true` only while the display link is actively driving frames: it reads `false` while auto-paused off-window, not just after `stopAnimating()`.
- It animates continuously via `CADisplayLink`, which can interfere with XCUITest's idle detection — disable it (e.g. skip `loadGIF` behind a launch argument) on screens you exercise with UI tests.

---

## 9. Form Validation — FieldsValidator

`FieldsValidator<Field: Hashable>` is a `@MainActor`, reactive form validator shipped in Common. You declare **rules** per field (pure declarations, no values baked in), feed values with `set(_:on:)`, and receive a recomputed `State` through `onChange`. The consumer supplies its own `Field` key type (any `Hashable`). The DemoApp Forms module is a worked example.

### Setup

```swift
private enum Field: Hashable { case name, email, password, confirmPassword }

// Explicit type annotation: the text fields' handlers reference `validator` back, and an
// inferred `lazy var` type in that cycle is a "circular reference" compile error.
private lazy var validator: FieldsValidator<Field> = .init(
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

**Where it lives.** The DemoApp keeps the validator in the `@MainActor` ViewModel: its `onChange` writes the latest `State` into an observed property and the controller renders errors and submit gating from it in `updateContent()`, so the VC holds no validation state; the VC-resident form above is the compact alternative. Either way the validator must be created on the main actor.

### Available rules

| Rule | Passes when |
|------|-------------|
| `.notEmpty` | Value is non-empty |
| `.minLength(n)` / `.maxLength(n)` | `count >= n` / `count <= n` |
| `.containsLetter` / `.containsLowercase` / `.containsUppercase` / `.containsNumber` | Contains a scalar of that class |
| `.contains(CharacterSet)` | Contains a scalar from the set |
| `.email` / `.rut` | Passes `String.isValidEmail` / `String.isRUT` |
| `.matches(Field)` / `.differs(from: Field)` | Equals / differs from another field's current value (an unset field reads as `""`, so `.matches` alone passes while both are empty — pair it with `.notEmpty`) |

Every rule has a non-empty `defaultMessage`; the `message` resolver overrides per `(Field, Rule)`. A resolver returning `""` enforces validity but **suppresses display** of that rule.

### State

`onChange` receives a `FieldsValidator<Field>.State` (nominal type, storable as `private(set) var validation: FieldsValidator<Field>.State?` on a ViewModel). The validator holds no field values; keep the ones you need for submission (name, email) in the ViewModel.

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
        // the token lives in your app (see §10/Storage).
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
Parameter encoding: POST/PUT/PATCH → JSON body (snake_case keys), GET → URL-encoded (snake_case keys)

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

`BaseClient.request(from:_:result:)` keys each in-flight request by its `from:` identifier (`#function` by default), per client instance: a new call cancels the earlier request with the same key, whose `result` handler then never fires. Duplicate taps therefore collapse only through a client you store; one created per call starts with an empty table and sends every request. The cancel-and-replace isn't atomic, so make the calls from one thread (the main actor, as UI code does).

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
    Task { @MainActor [weak self] in
        guard let self else { return }
        do {
            posts = try await PostClient().fetchPosts()              // observed state (behind a `revision`)
        } catch is CancellationError {
            return                                                   // a cancelled Task is not a failure to report
        } catch {
            event = .init(.failed(message: userMessage(for: error)))   // ViewEvent, consumed once by the controller
        }
    }
}

// App-side copy: NetworkError is not a LocalizedError, so its localizedDescription is a generic
// system string, and asString is diagnostic text for logs, not for users.
func userMessage(for error: Error) -> String {
    switch error as? NetworkError {
    case .requestError: "Check your connection and try again."
    case .responseError(let statusCode, _, _) where statusCode == 401: "Your session has expired."
    default: "Something went wrong. Please try again."
    }
}
```

`AsyncBaseClient` uses the same `Endpoint` router definitions as `BaseClient` — the two are interchangeable at the routing layer, but not in deduplication: `AsyncBaseClient` has none (its `from:` parameter is accepted and unused), so a request is abandoned by cancelling the `Task` that awaits it. Use `AsyncBaseClient` for new code where structured concurrency is available; use `BaseClient` when integrating with callback-based coordinator flows.

### BaseResponse wrapper

`BaseResponse` is **not part of the framework** — it's an app-side envelope
shape (like `alertView()` in Appendix A); define it in your project if your
backend wraps payloads this way:

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
productClient.list { [weak self] result in
    switch result {
    case .success(let products): self?.products = products                                      // observed state
    case .failure(let error):    self?.event = .init(.failed(message: userMessage(for: error)))  // a ViewEvent
    }
}
```

No `@unknown default` needed — `NetworkResultHandler` wraps `Swift.Result`,
which is a frozen enum; the two cases are exhaustive.

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
        guard let user else { onResult(.failure(.custom(message: "not_logged_in"))); return }
        checkoutClient.submit(.init(userId: user.id, cart: cart), result: onResult)
    }
}
```

Conform the screen's ViewModel. A coordinator conforms only for an app-level flow no screen owns, and a view controller never does (§7 *Where use cases live*):

```swift
extension CartViewModel: CheckoutUseCase {}
extension AppCoordinator: LogoutUseCase {}   // app-level, no screen owns it
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

### Test/override points

```swift
// Both live on HTTPService and apply to every request made through it:
HTTPService.defaultSession = mockSession       // inject a URLSession (tests)
HTTPService.defaultTimeoutInterval = 30        // default is 60s
```

### File upload (multipart)

```swift
func upload(using parameters: UploadParameters, result: @escaping NetworkResultHandler<EmptyResponse>) {
    HTTPService.upload(multipart: parameters.asMultipart, to: UploadRouter.upload, result: result)
}

// Or, on a BaseClient subclass, the instance form with in-flight dedup:
func upload(using parameters: UploadParameters, result: @escaping NetworkResultHandler<EmptyResponse>) {
    upload(from: #function, multipart: parameters.asMultipart, to: UploadRouter.upload, result: result)
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

### Do's and Don'ts

- **Do** define routes as enum cases conforming to `Endpoint`.
- **Do** use the UseCase pattern for reusable, testable networking logic.
- **Two valid client styles:** (a) subclass `BaseClient` and call `request(from: #function, ...)` — adds in-flight dedup keyed by `#function` per client instance (store the client; a later call cancels the earlier one); or (b) call `HTTPService.request(router, urlSession:, result:)` directly from the client method. The DemoApp uses (a). Pick one per client; both are supported.
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

### Direct `KeychainWrapper`

For raw Keychain access without the `KeyValueStore` facade:

```swift
KeychainWrapper.standard.set("token-value", forKey: "authToken")
let token = KeychainWrapper.standard.string(forKey: "authToken")
KeychainWrapper.standard.removeObject(forKey: "authToken")
```

- **Important:** individual operations are atomic (Security framework), but
  `KeychainWrapper` adds no synchronization of its own — a get-then-set
  sequence is **not** atomic across threads, and `standard` is shared
  process-wide. Serialize compound operations on one queue.
- Reads require a signed host process: in a hostless (fully unsigned) test
  bundle, SecItem calls silently return nothing.

### `FileStorage`

- **Warning:** `FileStorage` is **not thread-safe** and `shared` is an
  unsynchronized mutable static — confine access to one queue.

### Injecting storage in tests

`KeyValueStore` takes any `KeyValueStorage` backend — use the in-memory one
to keep tests hermetic:

```swift
let store = KeyValueStore(keyValueStorage: InMemoryKeyValueStorage())
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

Font families are declared by the app, not built into Common. Set up once at startup, then use `.appFont` everywhere:

```swift
// 1. Declare families in the app target — rawValue is the PostScript base name:
//    "varelaRound" resolves to "VarelaRound-Regular", "VarelaRound-Bold", etc.
extension AppFontFamily {
    static let montserrat  = AppFontFamily(rawValue: "montserrat")
    static let varelaRound = AppFontFamily(rawValue: "varelaRound")
}

// 2. Register the font files and pick the default family (e.g. in SceneDelegate).
//    No UIAppFonts Info.plist entry is needed; missing faces are skipped (logged in DEBUG).
UIFont.register(fonts: [.montserrat, .varelaRound])                  // "ttf" by default
UIFont.register(fonts: [.inter], styles: [.regular, .bold], type: "otf")
UIFont.setPrimaryFamily(.montserrat)
```

```swift
.font(.appFont(size: 16))                                     // regular, primary family
.font(.appFont(style: .bold, size: 14))
.font(.appFont(style: .medium, size: 16))
.font(.appFont(style: .semiBold, size: 14))
.font(.appFont(style: .extraBold, size: 24))
.font(.appFont(style: .black, size: 22))                      // heaviest weight
.font(.appFont(.varelaRound, size: 12))                       // explicit family
```

**Styles** (`UIFont.FontStyle`): `.thin`, `.extraLight`, `.light`, `.regular`, `.medium`, `.semiBold`, `.bold`, `.extraBold`, `.black`, `.italic`  
**Fallback:** an unset primary family or an unresolvable PostScript name returns the system font at the matching weight (`.thin` → `.thin` … `.medium` → `.medium` … `.extraBold` → `.heavy`, `.black` → `.black`; `.italic` → italic system font) — `.appFont` never fails.

**Migrating from an app-local `appFont` helper:** apps that predate this system (their own `UIFont` extension with a defaulted family parameter) can link Common as-is — the local helper keeps winning overload resolution over Common's `appFont(style:size:)`, so nothing changes until you opt in. To migrate: delete the local helper file, declare your `AppFontFamily` values, and call `setPrimaryFamily(_:)` at startup; label-only call sites compile unchanged.

### Colors

Common ships **no color palette** — only system colors and your own. Declare the app palette once and use it through the fluent API:

```swift
// App target
extension UIColor {
    static let gray600 = UIColor(red: 0.42, green: 0.45, blue: 0.49, alpha: 1)
    static let brandPurple = UIColor(named: "brandPurple")!
}

// Anywhere — system colors need no declaration
.textColor(.label).backgroundColor(.systemBackground).borderColor(.systemGray3)
.textColor(.gray600).backgroundColor(.brandPurple)
.black.withAlphaComponent(0.5)
```

(Names like `.gray600`, `.error`, `.backgroundPurple01` in consumer apps are *their* extensions, not framework API.)

### Images

```swift
// Named (from asset catalog)
UIImageView(image: .close)
UIImageView(image: .chevronRight)
UIImageView(image: .exclamationMark)

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
| `EmptyResultHandler` | `Handler<EmptyResult<Error>>` — `EmptyResult` is Common's own payload-less enum (`.success` / `.failure(Error)`), not `Swift.Result<Void, _>` |
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
| `ContentReloadable` | Views that can reload their content (legacy: new modules re-render from observed state) |
| `ViewLifecycleable` | View lifecycle event hooks |
| `CollectionViewable` | The list contract a ViewModel answers (`CollectionViewDataSourceable & CollectionViewDelegateable & CollectionViewSizeable`); sizes take `availableSize` |

### Module output types

| Type | Purpose |
|------|---------|
| `Handler<T>` | `(T) -> Void`; the type of `onRequested` / `onPerformed` closures |
| `ViewEvent<Payload>` | A one-shot effect as observed state: `UUID` identity + payload; assign a fresh value to fire (§5, §6) |
| `ViewEventCursor` | Controller-side `consume(_:_:)` that acts once per `ViewEvent` id inside `updateContent()` |

### Controller capability vocabulary

What a view controller can call, and how it gets it. Call these from the controller; never redeclare them on a protocol the ViewModel talks to. **Built in** means `UIViewController` itself conforms, so every view controller has it:

| Protocol | Grants | On a view controller |
|----------|--------|----------------------|
| `ActivityIndicatorable` | `startActivityIndicator()` / `stopActivityIndicator()`; `setActivityIndicator(visible:)` is the idempotent form for `updateContent()` | Built in |
| `AlertPresentable` | `presentAlertView(type:…)` / `presentAlertView(viewModel:…)` | Built in |
| `BackgroundColorable` | `backgroundColor(_:)` | Built in |
| `KeyboardDismissable` | `dismissKeyboard()` (pair with `setupAsKeyboardDismissable()`) | Built in |
| `LargeTitleSettable` | `enableLargeTitles()` / `disableLargeTitles()` | Built in |
| `NavigationBarVisibilityTogglable` | `showNavigationBar(animated:)` / `hideNavigationBar(animated:)` | Built in |
| `OffsetResetable` | `resetOffsetIfNeeded()` and its scroll/collection variants | Built in |
| `ScreenSizeMeasurable` | `screenWidth` / `screenHeight` (not for list sizes: use `availableSize`) | Built in |
| `TitleSettable` | `set(title:)` | Built in |
| `Vibrator` | `vibrate()` haptic | Built in |
| `SafariWebViewRequestable` | `onSafariWebViewRequested(url:)` presents an in-app Safari view | Declare the conformance; the default implementation does the rest |
| `AppSettingsRequestable` | `onAppSettingsRequested()` opens the app's Settings page | Declare the conformance; the default implementation does the rest |
| `BackButtonAddable` | An `addBackButton(_:handler:)` overload | Not needed: `addBackButton(_:action:)` (`addBackButton { }`) is a method on every view controller |
| `NavigationBarSetupable` | A `setupNavigationBar()` hook | No default: adopt it only when you implement the hook (an empty conformance doesn't compile) |
| `CameraSessionHandler` | `beginSession()` / `finishSession()` | No default and no adopter in Common: implement both |

---

## 15. Common Pitfalls and Best Practices

### Do

- **Always use `[weak self]` + `guard let self else { return }`** in closures to avoid retain cycles.
- **Set width on scroll content** (`.setWidth(to: $1.widthAnchor)`) to prevent horizontal scroll.
- **Use `.setRatio()` on images** to maintain aspect ratios.
- **Mark `init?(coder:)` unavailable** on a view controller that declares its own initializer (a `BaseViewController` subclass taking closures). A `BaseViewModelableViewController` subclass declares neither: `init(viewModel:)` is inherited, and declaring `init?(coder:)` removes it (Appendix B).
- **Prefer `.filled()` configuration** for primary action buttons, `.borderless()` for links.
- **Use `Task { @MainActor in }`** for UI updates from background threads — not `dispatchOnMain` or `DispatchQueue.main.async` (see the main-thread delivery note in section 5).
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
// Main thread dispatch — Swift Concurrency, not the legacy DispatchQueue helpers
Task { @MainActor in updateUI() }
Task { @MainActor in
    try? await Task.sleep(for: .seconds(0.5))
    animate()
}

// Haptics — vibrate() lives on UIViewController (via Vibrator); shake() on UIView
vibrate()        // from a UIViewController
view.shake()

// String formatting
string.removeRUTFormat()
string.formatAsRUT()
string.asDecimalNumber
string.trimmed   // trimmingCharacters(in: .whitespacesAndNewlines)

// Currency formatting lives on Int (es_CL locale)
1990.asCurrency   // "$1.990"

// Collections
array[safe: index]   // -> Element?; nil instead of out-of-bounds crash

// Logging — DEBUG only
Logger.log("some value")                          // generic item
Logger.log(["request": r, "response": s])        // structured items, printed in call-site order
// Keep `caller:` defaulted — Logger.log(caller: #function, [...]) resolves to the deprecated unordered overload.
Logger.log(request, data: data, response: resp)  // network request + response
// Logger output is compile-time gated: active in DEBUG builds, silenced in release.
// Logger.forceEnable() exists only in Debug builds of the framework SOURCE — it is compiled out
// in Release and absent from the SPM xcframework. Prefer the runtime gate below.
// To get logs in a debug app that links a *Release-built* Common.xcframework
// (the default SPM artefact), flip the runtime gate at startup:
//   #if DEBUG
//   Logger.isRuntimeForceEnabled(true)
//   HTTPService.shouldLog(true)    // and any other Loggable types you care about
//   #endif
// Order matters in Release builds: a <Type>.shouldLog(true) issued BEFORE isRuntimeForceEnabled(true) is dropped.
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
| `cachePolicy` | `CachePolicy` | `.default` | `.default` (L1 → L2 → network) or `.reloadIgnoringCache` (always fetch; cache updated on success) |
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

### Preloading

Warm the cache for images the user is about to see (e.g. the next page of a list). Preloads run at background priority and deduplicate against in-flight fetches, so a preloaded URL that a cell then requests joins the same task:

```swift
// Warm the cache for upcoming cells
await ImageLoader.shared.preload(urls: nextPageURLs)

// Cancel all in-flight preloads (e.g. in onViewWillDisappear)
await ImageLoader.shared.cancelPreloads()
```

Cancel preloads when the screen goes away — otherwise abandoned fetches keep running. `cancelPreloads()` only cancels fetches started by `preload(urls:)`; loads owned by visible image views are unaffected.

### Cache management

```swift
// ImageCache methods are synchronous — no await on either call
// Clear all cached images (memory + disk)
ImageLoader.shared.cache.clearAll()

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

## 18. System Managers & Utilities

The `Utils/Managers` surface — system-integration helpers you should reach for
before touching the frameworks directly.

### `Debouncer`

Collapses rapid repeated calls into one, keyed by call site (`#function`) plus
an optional id:

```swift
Debouncer.debounce(seconds: 0.5) { [weak self] in self?.performSearch() }
// Distinct debounce streams from one call site:
Debouncer.debounce(id: field.identifier, seconds: 0.5) { validate(field) }
```

### `LocalAuthenticationManager` — FaceID / TouchID / passcode

```swift
let auth = LocalAuthenticationManager(reason: "Unlock your account")

auth.localAuthenticationType   // .biometry(.faceId/.touchId/.opticId), .passcode, or .none
auth.canAuthenticate           // any policy available?

auth.authenticate { [weak self] success in
    success ? self?.unlock() : self?.showFallback()
}
```

The result handler is always delivered on the main thread; `false` covers both
denial and errors.

### `CameraManager` + `PreviewView`

Frame-capture pipeline: configure, then `begin` on a `PreviewView` — the
manager handles the authorization request, session setup, and frame delivery:

```swift
private lazy var previewView = PreviewView().videoGravity(.resizeAspectFill)

private lazy var camera = CameraManager(
    position: .back,
    onSampleBufferHandler: { [weak self] sampleBuffer in self?.process(sampleBuffer) }
)

camera.begin(previewView) { status in /* .authorized, .denied, ... */ }
camera.finish()                 // stop the session (e.g. onViewWillDisappear)
camera.set(zoomFactor: 2)
camera.toggleTorch()
```

### Authorization managers

Uniform `AuthorizationStatus` vocabulary over the system permission APIs:

```swift
CameraAuthorizationManager.currentStatus
CameraAuthorizationManager.requestAuthorization { granted in ... }

NotificationAuthorizationManager.getCurrentStatus { status in ... }
NotificationAuthorizationManager.requestAuthorization { granted in ... }  // .alert/.badge/.sound by default

LocationAuthorizationManager().request(.whenInUse) { status in ... }      // instance-based (CLLocationManager delegate)
```

### `NotificationRegisterManager`

APNs registration (pair with `NotificationAuthorizationManager` for the
permission first):

```swift
NotificationRegisterManager.registerForRemoteNotifications()
NotificationRegisterManager.unregisterForRemoteNotifications()
```

### `AppleLoginManager` — Sign in with Apple

```swift
private let appleLogin = AppleLoginManager()

appleLogin.performLogin(from: self) { result in
    switch result {
    case .success(let (credential, decodedToken)):
        // credential.asAppleUser → AppleUser(id, name, lastName, email)
        self.register(user: credential.asAppleUser, token: decodedToken)
    case .failure(let error):
        self.show(error)
    }
}
```

Keep the manager alive for the duration of the flow (it is the authorization
controller's delegate) — store it in a property, not a local.

Call `performLogin` once the anchor view controller is in a window (the manager falls back to the key window otherwise). `.canceled` and `.unknown` (the app lacks the Sign in with Apple entitlement) arrive as `.failure` with the system `ASAuthorizationError`; decode problems and a call made while another request is pending arrive as `AppleLoginError` (`.badToken`, `.malformedPayload`, `.alreadyInProgress`), a `LocalizedError`.

### `AppleSignInButton` — the button for that flow

```swift
private lazy var appleButton = AppleSignInButton()      // .adaptive: black on light, white on dark
    .onTap { [weak self] in guard let self else { return }
        appleLogin.performLogin(from: self) { result in /* as above */ }
    }
    .setConstraints { $0.set(height: 50) }

AppleSignInButton(type: .continue, style: .whiteOutline)   // fixed style; .black / .white / .whiteOutline
```

A `UIButton`-shaped wrapper around `ASAuthorizationAppleIDButton`: `.onTap`/target-action work, `isEnabled = false` really disables it, VoiceOver reads Apple's localized label, and the intrinsic size is Apple's. `.adaptive` follows interface-style changes (Apple's style is init-only, so the inner button is rebuilt on a flip).

### `NFCReadingAvailability`

```swift
guard NFCReadingAvailability.isReadingAvailable else { return showUnsupported() }
```

---

## 19. House Style

The framework's conventions — follow them for any code that lives in `Common/`
(and they translate well to consumer code):

- **File anatomy**: 3-line header (`//`, `//  Filename.swift`, `//`) — no
  author/copyright lines. One primary symbol per file. `// MARK: - SymbolName`
  per type; protocol conformances as separate `extension Type: Protocol {}`
  blocks at the bottom of the file, each with its own MARK.
- **Protocol taxonomy**: capabilities end in `-able` (`Navigationable`,
  `Actionable` — consistency beats grammar); `*Requestable` = a capability to
  request something, as `onXRequested` methods with a default implementation
  (`onAppSettingsRequested()`), adopted by whatever performs the request. It is
  not how a module reports upward: module outputs are the ViewModel's
  `onRequested` / `onPerformed` closures (§6). Behavior ships as protocol +
  constrained default implementation (`extension X where Self: Y`).
- **Fluent chainables**: `@discardableResult func x(_ value: X) -> Self { with { $0.x = value } }`,
  one file per chainable property (`UILabel+Font.swift`), rooted in `Withable`.
- **Closure vocabulary**: `Action`, `Handler<T>`, `NetworkResultHandler<T>`,
  `CompletionHandler` — a raw `(T) -> Void` in a public signature is a
  violation. Name protocol compositions (the legacy `BaseModuleDelegate` is one).
- **Semantic sugar**: `.empty` over `""`, `.zero` over `0`, `.init()` shorthand
  where the type is inferable, `.isNotNil` / `.isNotEmpty` over negations.
- **DocC on every public symbol**; `- Note:` / `- Warning:` / `- Important:`
  for gotchas; inline comments only for invariants and "why", never "what".
- **Class discipline**: `open class Base*` for extension points, `final class`
  for leaves; UI types are `@MainActor`; singletons are `static let shared` +
  `private init()`; nearly every parameter gets a default value; Debug traps
  via `assertionFailure`, Release degrades gracefully.
- **Modern Swift**: one-line trivial bodies, switch expressions,
  `guard let self`, `some Protocol` parameters, `#function`-keyed identity.

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
- [ ] `BaseViewController` subclass taking closures: custom `init` + `required init?(coder:)` marked `@available(*, unavailable)`. `BaseViewModelableViewController` subclass: **no** initializer — `init(viewModel:)` is inherited and declaring `init?(coder:)` removes it
- [ ] ViewModel and the wireframe's `createModule` are `@MainActor`
- [ ] `@UIViewBuilder override var mainView: UIView` with `VStack`/`HStack` layout
- [ ] `override func setupView()` calls `super.setupView()` first
- [ ] Lifecycle logic uses `onViewIsAppearing`, `onViewWillDisappear` hooks — not overrides
- [ ] ViewModel is `@Observable`; the controller renders its state in `updateContent()` (`super.updateContent()` first); one-shot effects are a `ViewEvent` slot consumed by the controller's `ViewEventCursor` (§5 *Observation-driven updates*)
- [ ] ViewModel holds no `view`, `delegate` or coordinator reference; its outputs are `onRequested` / `onPerformed` closures over nested `Requested` / `Performed` enums (§6)
- [ ] Lists size through `onSizeForItem(in:at:availableSize:)` — no `screenWidth` reads
- [ ] All closures capture `[weak self]` and immediately `guard let self else { return }`
- [ ] Network calls go through a `UseCase` the ViewModel conforms to (§7 *Where use cases live*)
- [ ] Navigation fired through a ViewModel intent → `onRequested(.action)`; the coordinator answers. Modal effects over the screen (alert, snackbar) are `ViewEvent`s the controller presents

---

## Appendix C — New API domain checklist

- [ ] `enum MyRouter` with one case per endpoint
- [ ] `extension MyRouter: Endpoint` — implement `baseURL`, `path`, `method`, `headers`, `parameters`. `basePath` and `version` are optional (both default to empty; `url` appends `basePath`, `version` and `path` verbatim, so write the slashes). Parameters are encoded with snake_case keys (a JSON body for POST/PUT/PATCH, the query string for GET/HEAD/DELETE); override `jsonEncoder` or `urlEncodedFormEncoder` on the router to change that
- [ ] If the endpoint requires auth, resolve the token inline in `headers` from an app-level Storage type (Common has no token-resolution protocol)
- [ ] `protocol MyClientProtocol: AnyObject` with method signatures using `NetworkResultHandler<T>`
- [ ] `final class MyClient: BaseClient` (empty body)
- [ ] `extension MyClient: MyClientProtocol` — style (a): `request(from: #function, router, result:)` on `BaseClient`; or style (b): direct `HTTPService.request(router, result:)` (see §10 Do's and Don'ts)
- [ ] `protocol MyUseCase` + `extension MyUseCase` with default implementation
- [ ] Conform the screen's ViewModel to `MyUseCase` (a coordinator only for an app-level flow no screen owns; never a view controller)
