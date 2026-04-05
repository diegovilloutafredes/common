# Common Package

A foundational library for iOS development, providing core architectural patterns, networking abstractions, UI components, and extensive framework utilities.

## Overview

The `Common` package serves as a robust foundation for building iOS applications and libraries. It encapsulates shared logic and design patterns to ensure consistency, scalability, and ease of development.

The project implements MVVM-C well. `BaseCoordinator` cleanly separates navigation logic from view controllers. The `ViewModelable` protocol hierarchy drives UI updates, and protocol composition via type aliases (e.g. `ViewModelableViewController`) is a standout strength — highly composable without deep inheritance chains. `UIViewBuilder` provides a SwiftUI-like DSL over UIKit, well-executed.

## Key Features

- **MVVM-C Architecture**: Built-in support for Model-View-ViewModel-Coordinator patterns.
- **Declarative UI**: Custom DSLs and Result Builders (`@UIViewBuilder`) for concise, SwiftUI-like view construction using UIKit.
- **Robust Networking**: A protocol-oriented networking layer with automatic parameter encoding and response decoding.
- **Secure & Flexible Storage**: Typed storage solutions including Keychain, Key-Value stores, and File storage.
- **Comprehensive UI Toolkit**: A rich set of base classes (`BaseView`, `BaseCell`) and custom components (`ActionButton`, `AlertView`, etc.).
- **Extensive Framework Extensions**: 400+ extensions for UIKit, Foundation, AVFoundation, and more, providing a fluent API for layouts, animations, and styling.
- **System Managers**: Ready-to-use managers for Apple Login, Local Authentication (FaceID/TouchID), Camera sessions, and Notifications.

## Architecture

The package promotes a clean separation of concerns across four main layers:

- **Coordinators**: `BaseCoordinator` manages navigation flow and child coordinator hierarchies. `PopType`/`DismissType` enums with associated values replace boolean navigation flags with explicit, type-safe choices.
- **ViewControllers**: `BaseViewModelableViewController` provides a standard lifecycle and automatic ViewModel binding.
- **Views**: `BaseView` and `BaseCell` integrate with `UIViewBuilder` for declarative layouts. `ArrayBuilder` handles optionals and conditionals for flexible view composition.
- **Protocols**: 35+ protocols (e.g. `Navigationable`, `AlertPresentable`, `ViewModelable`) with default implementations define the library's flexible and testable contract. `BaseModuleDelegate` type alias composing multiple protocols cleanly expresses module boundaries.

## Usage Highlights

### Declarative Layouts

```swift
@UIViewBuilder override var mainView: UIView {
    VStack(spacing: 20) {
        UILabel()
            .text("Welcome")
            .font(.boldSystemFont(ofSize: 24))

        ActionButton()
            .title("Get Started")
            .onTap { self.viewModel.start() }
    }
    .snap(to: self.view)
}
```

### Networking

```swift
class MyClient: BaseClient {
    func fetchData(completion: @escaping NetworkResultHandler<MyData>) {
        request(from: #function, MyEndpoint.getData, result: completion)
    }
}
```

## Documentation

The codebase is 100% documented with DocC comments. You can generate and view the HTML version using Jazzy:

- **Location**: `docs/index.html`

---

## Technical Analysis

### Strengths

- **Protocol-driven design** — 35+ protocols with default implementations create a flexible, composable system
- **HTTPHeaders** — case-insensitive, collection-conforming, well-encapsulated
- **NetworkError enum** — comprehensive, distinguishes decoding/network/response failures, includes response data for debugging
- **Storage abstraction** — clean single interface over UserDefaults, Keychain, and file system
- **Documentation** — thorough DocC coverage throughout
- **Dispatch helpers** (`dispatchOnMain`, `dispatchOnGlobal`) reduce boilerplate consistently

### Weaknesses / Concerns

**High Risk**
- **Force cast in `ViewModelSettable`** — `viewModel as! ViewModelType` will crash if the wrong type is passed. Should use safe casting with a clear error path.
- **Thread safety** — `BaseClient.requests` dictionary (`[String: URLSessionTask]`) has no synchronization. Concurrent network callbacks can corrupt state.

**Medium Risk**
- **`HTTPService` request timing** — stores timing in a global `KeyValueStore` with string keys (`"beforeRequestTime"`). Concurrent requests will overwrite each other's timing data.
- **No async/await** — all networking uses completion handlers. Modern Swift concurrency would significantly improve readability and safety.
- **`HTTPService` is a static enum** — can't inject a custom `URLSession`, making unit testing and SSL pinning impossible without workarounds.
- **No retry or timeout logic** — transient failures silently return errors with no recovery path.

**Low Risk / Code Quality**
- **418 extension files** — extremely fragmented. One file per extension method makes discovery hard. Grouping by domain would help.
- Logging fires on every `requests` dictionary update — very noisy in production, not gated by environment.
- Duplicate `// MARK: -` comments in several files.

### Priority Recommendations

| Priority | Action |
|---|---|
| 1 | Replace force cast in `ViewModelSettable` with safe casting |
| 2 | Add thread safety to `BaseClient.requests` (`@MainActor` or a serial queue) |
| 3 | Fix concurrent request timing — use per-request context, not global storage |
| 4 | Refactor `HTTPService` to a protocol + default implementation for testability |
| 5 | Add async/await networking layer (can coexist with callbacks during migration) |

**Overall: B+** — solid architecture and good patterns, but the force cast, thread safety gaps, and untestable network layer are the main issues to address before heavy production use.
