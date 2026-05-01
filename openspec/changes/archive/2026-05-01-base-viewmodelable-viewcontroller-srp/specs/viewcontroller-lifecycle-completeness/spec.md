## ADDED Requirements

### Requirement: BaseViewController forwards viewDidDisappear
`BaseViewController` SHALL override `viewDidDisappear(_:animated:)`, call `super`, and emit a Logger entry, so that subclasses that override it always have a consistent base implementation.

#### Scenario: viewDidDisappear is called on a BaseViewController subclass
- **WHEN** a screen is popped or dismissed and `viewDidDisappear` fires
- **THEN** `super.viewDidDisappear(animated)` is called and a log entry for the calling type is emitted

### Requirement: BaseViewModelableViewController forwards onViewDidDisappear
`BaseViewModelableViewController` SHALL override `viewDidDisappear(_:animated:)` and forward to `ViewLifecycleable.onViewDidDisappear()` on the ViewModel, consistent with all other lifecycle hooks.

#### Scenario: ViewModel receives onViewDidDisappear
- **WHEN** a screen disappears (popped, dismissed, or covered by another modal)
- **THEN** `viewModel.onViewDidDisappear()` is called exactly once per disappearance

### Requirement: BaseViewController.loadView sets mainView as root view directly
`BaseViewController.loadView()` SHALL assign `mainView` directly to `self.view` with no intermediate container `UIView`.

#### Scenario: View hierarchy has no spurious wrapper node
- **WHEN** a `BaseViewController` subclass is loaded
- **THEN** `self.view` IS `mainView` (identity equality), not a container wrapping it

#### Scenario: mainView setConstraints still fires
- **WHEN** `mainView` is set as `self.view` and it has a registered `setConstraints` handler
- **THEN** the handler fires during the view loading sequence and the mainView is correctly constrained within the view controller's safe area or layout guides

### Requirement: ViewModel role casts are cached at init in BaseViewModelableViewController
`BaseViewModelableViewController` SHALL compute and store `ViewLifecycleable`, `CollectionViewable`, and `ReloadContentRequestable` role casts once at initialisation (or when `viewModel` changes) rather than on every method call.

#### Scenario: Lifecycle callback performance
- **WHEN** `viewWillAppear` fires ten times (e.g. push/pop cycle)
- **THEN** the `viewModel as? ViewLifecycleable` cast executes at most once per ViewModel assignment, not once per lifecycle event
