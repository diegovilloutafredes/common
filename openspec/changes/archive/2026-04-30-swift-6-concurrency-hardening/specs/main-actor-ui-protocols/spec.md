## ADDED Requirements

### Requirement: UIKit-facing protocols are MainActor-isolated
The protocols `ActivityIndicatorable`, `AlertPresentable`, `Dismissable`, `Navigationable`, `Presentable`, and `ViewLifecycleable` SHALL be annotated with `@MainActor` so the Swift compiler enforces main-thread usage at conformance sites.

#### Scenario: Conforming type on non-main actor
- **WHEN** a type that is NOT `@MainActor` conforms to any of the listed protocols
- **THEN** the compiler emits an error or requires an explicit `@MainActor` annotation at the conformance site

#### Scenario: UIViewController conformance compiles without change
- **WHEN** a `UIViewController` subclass conforms to `ActivityIndicatorable` or `Navigationable`
- **THEN** no new compiler errors are introduced (UIViewController is already `@MainActor`)

### Requirement: BaseCoordinator is MainActor-annotated
`BaseCoordinator` SHALL be declared `@MainActor` so all navigation, alert, and dismiss calls it makes are compiler-verified to run on the main thread.

#### Scenario: Coordinator navigation calls are safe
- **WHEN** `BaseCoordinator.push(_:)` or `BaseCoordinator.present(_:)` is called
- **THEN** the Swift compiler enforces that the call site is on the main actor

#### Scenario: Child coordinator start from non-main context
- **WHEN** `addChildAndStart` is called from a background Task
- **THEN** the compiler requires a `MainActor.run {}` or `await MainActor.run {}` wrapper

### Requirement: dispatchOnMain is a no-op dispatch when already on main
`dispatchOnMain(_:)` SHALL execute the closure synchronously when called from the main thread, instead of scheduling it asynchronously on the next run-loop cycle.

#### Scenario: Call from main thread
- **WHEN** `dispatchOnMain { ... }` is called while `Thread.isMainThread == true`
- **THEN** the closure executes before `dispatchOnMain` returns

#### Scenario: Call from background thread
- **WHEN** `dispatchOnMain { ... }` is called from a background thread
- **THEN** the closure is dispatched asynchronously to the main queue (existing behaviour unchanged)
