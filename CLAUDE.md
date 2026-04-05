# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build XCFramework (device + simulator, output to XCFramework/)
make create_xcframework
# or directly:
./create_xcframework.sh

# Build for a specific SDK (without archiving)
xcodebuild build -scheme Common -sdk iphoneos
xcodebuild build -scheme Common -sdk iphonesimulator
```

The framework targets **iOS 15.0+**, Swift 5.0. There are no unit tests or linting tools configured.

## Documentation

The codebase is 100% documented with DocC comments. HTML docs (Jazzy-generated) live in `docs/` and are committed to the repo. View at `docs/index.html`.

## Architecture

This is an **Xcode framework project** (not SPM). The `Common` target produces `Common.framework`; `DemoApp` is a sample app showing usage.

### MVVM-C Pattern

- **Coordinators** (`Architecture/`): `BaseCoordinator` manages navigation flow and child coordinator hierarchies.
- **ViewControllers** (`ViewControllers/`): `BaseViewModelableViewController` provides standard lifecycle and automatic ViewModel binding.
- **Views** (`Views/`): `BaseView` and `BaseCell` use `@UIViewBuilder` for declarative UIKit layouts.
- **Protocols** (`Protocols/`): 30+ protocols (`Navigationable`, `AlertPresentable`, `ViewModelable`, `Actionable`, `DismissRequestable`, etc.) define the contracts between layers.

### Declarative UI DSL

Views are built using `@UIViewBuilder` (a result builder) with `VStack`, `HStack`, `VList`, `HList` container types defined in `Views/`. This enables SwiftUI-like layout syntax in UIKit — use `.snap(to:)` to constrain to a superview.

### Networking (`Network/`)

`BaseClient` provides the HTTP networking base. `HTTPService` handles actual requests. Implement endpoints conforming to the networking protocols and call `request(from:_:result:)`. Supports multipart uploads.

### Storage (`Storage/`)

Three typed storage options: `KeychainWrapper` (secure), `KeyValueStore` (UserDefaults-backed), `FileStorage` (file system).

### Extensions (`Extensions/`)

400+ extensions across 49 categories (UIKit, Foundation, AVFoundation, CoreGraphics, Vision, etc.). When looking for a utility, check here before adding new code — the extension likely already exists.

### Utils (`Utils/`)

System integration managers: `AppleLoginManager`, `LocalAuthenticationManager` (FaceID/TouchID), `CameraManager`, `NotificationRegisterManager`. Also: `Logger`, `Debouncer`.

### Global Types

- `Global.swift`: Dispatch helpers, `EmptyResult` type alias
- `TypeAliases.swift`: 83+ type aliases for result handlers and protocol compositions
