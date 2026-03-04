# Common Package

A foundational library for iOS development, providing core architectural patterns, networking abstractions, UI components, and extensive framework utilities.

## Overview

The `Common` package serves as a robust foundation for building iOS applications and libraries. It encapsulates shared logic and design patterns to ensure consistency, scalability, and ease of development.

## Key Features

- **MVVM-C Architecture**: Built-in support for Model-View-ViewModel-Coordinator patterns.
- **Declarative UI**: Custom DSLs and Result Builders (`@UIViewBuilder`) for concise, SwiftUI-like view construction using UIKit.
- **Robust Networking**: A protocol-oriented networking layer with automatic parameter encoding and response decoding.
- **Secure & Flexible Storage**: Typed storage solutions including Keychain, Key-Value stores, and File storage.
- **Comprehensive UI Toolkit**: A rich set of base classes (`BaseView`, `BaseCell`) and custom components (`ActionButton`, `AlertView`, etc.).
- **Extensive Framework Extensions**: 400+ extensions for UIKit, Foundation, AVFoundation, and more, providing a fluent API for layouts, animations, and styling.
- **System Managers**: Ready-to-use managers for Apple Login, Local Authentication (FaceID/TouchID), Camera sessions, and Notifications.

## Architecture

The package promotes a clean separation of concerns:

- **Coordinators**: `BaseCoordinator` manages navigation flow and child coordinator hierarchies.
- **ViewControllers**: `BaseViewModelableViewController` provides a standard lifecycle and automatic View Model binding.
- **Views**: `BaseView` and `BaseCell` integrate with `UIViewBuilder` for declarative layouts.
- **Protocols**: A set of 30+ protocols (e.g., `Navigationable`, `AlertPresentable`, `ViewModelable`) defines the library's flexible and testable contract.

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
- **Jazzy Command**: `jazzy --xcodebuild-arguments -workspace,TrustBioIdentity.xcworkspace,-scheme,Common --module Common --output Common/docs`