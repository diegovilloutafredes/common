# Common

[![CI & Documentation](https://github.com/diegovilloutafredes/common/actions/workflows/ci.yml/badge.svg)](https://github.com/diegovilloutafredes/common/actions/workflows/ci.yml)

A foundational library for iOS development, providing core architectural patterns, networking abstractions, UI components, and extensive framework utilities.

## Requirements

- iOS 16.0+
- Swift 5.9+
- Xcode 16.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for local development)

## Installation

### Swift Package Manager

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/diegovilloutafredes/common.git", from: "1.0.0")
]
```

Then add `"Common"` to the dependencies of any target that uses it:

```swift
.target(
    name: "YourTarget",
    dependencies: ["Common"]
)
```

Or in Xcode: **File → Add Package Dependencies…** and enter the repository URL.

## Overview

The `Common` package serves as a robust foundation for building iOS applications and libraries. It encapsulates shared logic and design patterns to ensure consistency, scalability, and ease of development.

The project implements the MVVM-C pattern. `BaseCoordinator` cleanly separates navigation logic from view controllers. The `ViewModelable` protocol hierarchy drives UI updates, and protocol composition via type aliases (e.g. `ViewModelableViewController`) keeps things highly composable without deep inheritance chains. `UIViewBuilder` provides a SwiftUI-like DSL over UIKit.

## Key Features

- **MVVM-C Architecture** — Built-in support for Model-View-ViewModel-Coordinator patterns.
- **Declarative UI** — Custom DSLs and Result Builders (`@UIViewBuilder`) for concise, SwiftUI-like view construction using UIKit.
- **Robust Networking** — A protocol-oriented networking layer with automatic parameter encoding and response decoding.
- **Secure & Flexible Storage** — Typed storage solutions including Keychain, Key-Value stores, and File storage.
- **Comprehensive UI Toolkit** — A rich set of base classes (`BaseView`, `BaseCell`) and custom components (`ActionButton`, `AlertView`, etc.).
- **Extensive Framework Extensions** — 400+ extensions for UIKit, Foundation, AVFoundation, and more, providing a fluent API for layouts, animations, and styling.
- **System Managers** — Ready-to-use managers for Apple Login, Local Authentication (FaceID/TouchID), Camera sessions, and Notifications.

## Architecture

The package promotes a clean separation of concerns across four main layers:

- **Coordinators** — `BaseCoordinator` manages navigation flow and child coordinator hierarchies. `PopType`/`DismissType` enums with associated values replace boolean navigation flags with explicit, type-safe choices.
- **ViewControllers** — `BaseViewModelableViewController` provides a standard lifecycle and automatic ViewModel binding.
- **Views** — `BaseView` and `BaseCell` integrate with `UIViewBuilder` for declarative layouts. `ArrayBuilder` handles optionals and conditionals for flexible view composition.
- **Protocols** — 35+ protocols (e.g. `Navigationable`, `AlertPresentable`, `ViewModelable`) with default implementations define the library's flexible and testable contract.

## Usage

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

## Local Development

The Xcode project is generated from `project.yml` using [XcodeGen](https://github.com/yonaskolb/XcodeGen) and is not committed to source control.

```bash
brew install xcodegen
xcodegen generate
open Common.xcodeproj
```

Re-run `xcodegen generate` (or `make generate`) whenever `project.yml` changes.

## Demo App

The project includes a `DemoApp` target that showcases the library's capabilities, including networking, UI components, and architectural patterns. Build and run the `DemoApp` scheme in Xcode to explore.

## Documentation

The codebase is fully documented with DocC comments. You can generate the HTML documentation using [Jazzy](https://github.com/realm/jazzy):

```bash
jazzy
```

The output is available at `docs/index.html`.

## Versioning

This project uses [Semantic Versioning](https://semver.org/). Releases are managed via Git tags:

```bash
git tag 1.0.0
git push origin 1.0.0
```

## License

See [LICENSE](LICENSE) for details.
