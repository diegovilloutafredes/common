# Common

[![CI & Documentation](https://github.com/diegovilloutafredes/common/actions/workflows/ci.yml/badge.svg)](https://github.com/diegovilloutafredes/common/actions/workflows/ci.yml)

A foundational iOS library that lets you build complete, production-ready features in a fraction of the usual boilerplate. Write declarative UIKit screens, wire MVVM-C modules, load and cache images, persist data to Keychain or UserDefaults, authenticate with Face ID, and more — all through a consistent, composable API.

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

> **Binary distribution:** Common ships as a prebuilt XCFramework (binary target compiled with `BUILD_LIBRARY_FOR_DISTRIBUTION=YES`). You get ABI-stable symbols and do not build from source. The resolved package resolves to the xcframework committed at the tagged version.

---

## What you can build

| Capability | API surface |
|---|---|
| Declarative UIKit screens | `@UIViewBuilder`, `VStack`, `HStack`, fluent extensions |
| Custom font pipeline | `AppFontFamily`, `UIFont.register(fonts:)`, `.appFont(style:size:)` |
| Complete MVVM-C modules | `BaseCoordinator`, `BaseViewModelableViewController`, wireframe factory |
| Declarative form validation | `FieldsValidator`, cross-field `.matches`/`.differs`, built-in touched-state |
| Async HTTP networking | `AsyncBaseClient`, `Endpoint`, `HTTPService` |
| Remote image loading with two-tier cache | `UIImageView.loadImage(from:options:)`, `ImageLoader` |
| Typed Keychain / UserDefaults / file storage | `KeyValueStore`, `SingleRawValueKeyValueObjectStorage` |
| Face ID / Touch ID / passcode gate | `LocalAuthenticationManager` |
| Sign in with Apple | `AppleLoginManager` |
| Feedback UI (toasts, snackbars, modals) | `Snackbar`, `Toast`, `CustomAlertWireframe` |
| Debounced input | `Debouncer.debounce(seconds:function:)` |
| AES-128/256 encryption | `AES(key:iv:)` |
| 400+ UIKit, Foundation, and AVFoundation extensions | `Extensions/` |

---

## Usage

### Declarative UIKit layouts

Build entire screens with a SwiftUI-like DSL — no storyboards, no raw `NSLayoutConstraint`, no frames. `VStack` and `HStack` map directly to `UIStackView` with named parameters. The result builder handles optionals and conditionals natively.

```swift
final class ProfileViewController: BaseViewModelableViewController<ProfileViewModelProtocol> {

    private lazy var avatarView = UIImageView()
        .contentMode(.scaleAspectFill)
        .round(radius: 40)
        .set(width: 80).setRatio()

    private lazy var nameLabel = UILabel()
        .font(.boldSystemFont(ofSize: 22))
        .textColor(.label)

    private lazy var bioLabel = UILabel()
        .font(.systemFont(ofSize: 15))
        .textColor(.secondaryLabel)
        .numberOfLines()

    private lazy var followButton = UIButton(configuration: .filled()
        .attributedTitle(.init("Follow"))
        .baseBackgroundColor(.systemBlue)
        .baseForegroundColor(.white)
        .cornerStyle(.capsule)
    ).onTap { [weak self] in self?.viewModel.follow() }
     .setRatio(200 / 44)

    @UIViewBuilder override var mainView: UIView {
        VStack(alignment: .center, margins: .init(all: 24), spacing: 16) {
            avatarView
            nameLabel
            bioLabel
            followButton
        }
        .setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }
}
```

**Container options:**

```swift
// Horizontal row, equally distributed
HStack(distribution: .fillEqually, spacing: 12) { button1; button2 }

// Card-style container
VStack(margins: .init(all: 16), spacing: 12) { titleLabel; bodyLabel }
    .backgroundColor(.secondarySystemBackground)
    .round(radius: 16)
    .shadow(color: .black.withAlphaComponent(0.12), offset: .init(width: 0, height: 4), opacity: 1, radius: 12)
```

**Common constraint helpers:**

```swift
// Fill safe area
.setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }

// Safe area top + extend to bottom edge (behind tab bar)
.setConstraints { $0.snapLeadTopTrail(to: $1.safeAreaLayoutGuide); $0.snapBottom(to: $1) }

// Push content up with keyboard
.setConstraints { $0.snapLeadTopTrail(to: $1.safeAreaLayoutGuide); $0.pinBottom(to: $1.keyboardLayoutGuide.topAnchor) }
```

---

### Custom fonts

Declare your families, register the font files at startup — no `UIAppFonts` Info.plist entry needed — and style text with `.appFont` everywhere. Font files just need to be bundle resources named after their PostScript names (`Montserrat-Bold.ttf`).

```swift
extension AppFontFamily {
    static let montserrat = AppFontFamily(rawValue: "montserrat")   // → "Montserrat-Bold", ...
}

// At startup (e.g. SceneDelegate):
UIFont.register(fonts: [.montserrat])
UIFont.setPrimaryFamily(.montserrat)

// Anywhere:
titleLabel.font(.appFont(style: .bold, size: 24))            // primary family
captionLabel.font(.appFont(.montserrat, size: 13))           // explicit family
```

Missing faces and unregistered families fall back to a weight-matched system font.

---

### MVVM-C module wiring

Each feature is a self-contained module: a **Wireframe** factory wires the ViewModel and ViewController together, while the **Coordinator** owns navigation. The ViewController never knows about navigation; it only fires typed actions back through a closure.

```swift
// 1. Action enum — what the module can request from the coordinator
enum ProfileAction {
    case editProfile
    case showFollowers
}

// 2. Wireframe — creates and wires the module
enum ProfileWireframe {
    static func createModule(
        with delegate: BaseModuleDelegate,
        onAction: @escaping Handler<ProfileAction>
    ) -> UIViewController {
        let vm = ProfileViewModel(delegate: delegate, onAction: onAction)
        return ProfileViewController(viewModel: vm)
            .with { vm.view = $0 }   // wires VM → VC reference
    }
}

// 3. Coordinator — owns navigation
final class AppCoordinator: BaseCoordinator {
    override func start() {
        let vc = ProfileWireframe.createModule(with: self) { [weak self] action in
            switch action {
            case .editProfile:  self?.push(EditProfileWireframe.createModule(with: self!) { _ in })
            case .showFollowers: self?.present(.overCurrent, viewController: FollowersWireframe.createModule(with: self!) { _ in })
            }
        }
        set(vc)
    }
}

// 4. ViewModel — communicates down to the VC via a weak view reference
final class ProfileViewModel {
    private weak var delegate: BaseModuleDelegate?
    private let onAction: Handler<ProfileAction>
    weak var view: ProfileViewProtocol?

    init(delegate: BaseModuleDelegate, onAction: @escaping Handler<ProfileAction>) {
        self.delegate = delegate
        self.onAction = onAction
    }
}

extension ProfileViewModel: ProfileViewModelProtocol {}

extension ProfileViewModel: ViewLifecycleable {
    func onViewDidLoad() {
        view?.addBackButton { self.delegate?.onGoBackRequested() }
    }
}
```

Navigation methods available on any coordinator (via `Navigationable`):

```swift
set(vc)                                    // replace root
push(vc)                                   // push onto stack
pop()  /  pop(.toRoot)  /  pop(.to(vc))   // pop variants
present(.overCurrent, viewController: vc)  // modal
dismiss()                                  // dismiss modal
```

---

### Form validation

`FieldsValidator<Field>` validates form fields declaratively. Declare rules per field, feed values as the user types, and react to a recomputed state. Errors stay hidden until a field is touched, and cross-field rules like `.matches` resolve against another field's current value automatically.

```swift
enum Field { case email, password, confirmPassword }

let validator = FieldsValidator<Field>(
    rules: [
        .email:           [.notEmpty, .email],
        .password:        [.notEmpty, .minLength(8)],
        .confirmPassword: [.notEmpty, .matches(.password)]
    ],
    onChange: { state in
        submitButton.isEnabled(state.isValid)        // overall validity
        for (field, fieldState) in state.fields {
            errorLabel(for: field).text(fieldState.message)   // nil clears
        }
    }
)

emailField.onEditingChanged { validator.set($0.text, on: .email) }
```

### Async networking

Subclass `AsyncBaseClient` and define your endpoint. Responses are decoded automatically; errors are typed.

```swift
// 1. Define the endpoint
enum UserEndpoint: Endpoint {
    case getUser(id: String)
    case updateBio(id: String, bio: String)

    var baseURL: URL { URL(string: "https://api.example.com")! }

    var path: String {
        switch self {
        case .getUser(let id):    return "/users/\(id)"
        case .updateBio(let id, _): return "/users/\(id)/bio"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getUser:   return .get
        case .updateBio: return .patch
        }
    }

    var headers: HTTPHeaders? { ["Authorization": "Bearer \(token)"] }

    var parameters: Encodable? {
        switch self {
        case .updateBio(_, let bio): return ["bio": bio]
        default: return nil
        }
    }
}

// 2. Build the client
final class UserClient: AsyncBaseClient {
    func fetchUser(id: String) async throws -> User {
        try await request(UserEndpoint.getUser(id: id))
    }

    func updateBio(id: String, bio: String) async throws -> User {
        try await request(UserEndpoint.updateBio(id: id, bio: bio))
    }
}

// 3. Call from a ViewModel
func loadUser() async {
    do {
        let user = try await UserClient().fetchUser(id: currentUserId)
        await MainActor.run { view?.display(user: user) }
    } catch let error as NetworkError {
        await MainActor.run { view?.showError(error.localizedDescription) }
    }
}
```

---

### Remote image loading

`UIImageView.loadImage(from:options:)` handles the full lifecycle: L1 memory cache → L2 disk cache → network fetch. Concurrent requests for the same URL are automatically deduplicated. A `Task` is returned so you can cancel mid-flight.

```swift
// Simple load with a placeholder
avatarView.loadImage(
    from: user.avatarURL,
    options: ImageLoadOptions(
        placeholder: UIImage(systemName: "person.crop.circle"),
        failureImage: UIImage(systemName: "exclamationmark.triangle"),
        transition: .fade(0.25)
    )
)

// Force a fresh fetch, bypassing the cache
avatarView.loadImage(from: url, options: ImageLoadOptions(cachePolicy: .reloadIgnoringCache))

// Cancel the load when the cell is reused
override func prepareForReuse() {
    super.prepareForReuse()
    avatarView.cancelImageLoad()
}

// Preload a list of upcoming images at background priority
await ImageLoader.shared.preload(urls: nextPageURLs)

// Cancel all in-flight preloads (e.g. the user left the screen)
ImageLoader.shared.cancelPreloads()
```

---

### Padded labels & animated GIFs

`PaddingLabel` is a `UILabel` with configurable content insets (chips, tags, badges) — the padding is reflected in its intrinsic size and wrapped multi-line text stays within the insets. `GIFImageView` plays animated GIFs via ImageIO, decoding one frame at a time on a `CADisplayLink` (flat memory) and pausing off-screen.

```swift
// A padded, rounded badge
PaddingLabel(padding: .init(all: 4))
    .text("NEW")
    .backgroundColor(.systemPink)
    .setAsRoundedView(radius: 4)

// An animated GIF
let gif = GIFImageView()
gif.loadGIF(named: "spinner")          // "spinner.gif" in the main bundle
// or: gif.loadGIF(from: data)
```

---

### Typed storage

One unified interface for Keychain, UserDefaults, and file storage. Define a typed schema once and get `add`/`get`/`delete` for free.

```swift
// Keychain (secure) — wrap a single item type behind a clean API
struct TokenStorage: SingleRawValueKeyValueObjectStorage {
    var type: KeyValueStore.StoreType { .secure }
    enum Keys: String { case token }
    typealias Item = String

    func add(item: String) { add(item: (.token, item)) }
    func get() -> String? { get(using: .token) }
    func delete() { remove(using: .token) }
}

// Use it:
var auth = TokenStorage()
auth.add(item: receivedToken)
let stored: String? = auth.get()
auth.delete()

// UserDefaults — for user preferences
struct OnboardingStorage: SingleRawValueKeyValueObjectStorage {
    var type: KeyValueStore.StoreType { .notSecure(.userDefaults) }
    enum Keys: String { case hasSeenOnboarding }
    typealias Item = Bool

    func add(item: Bool) { add(item: (.hasSeenOnboarding, item)) }
    func get() -> Bool? { get(using: .hasSeenOnboarding) }
    func delete() { remove(using: .hasSeenOnboarding) }
}
```

Swap in `InMemoryKeyValueStorage` during tests — no disk side-effects, and `reset()` between cases:

```swift
final class TokenStorageTests: XCTestCase {
    var storage: InMemoryKeyValueStorage!

    override func setUp() {
        storage = InMemoryKeyValueStorage()
        // inject into the object under test
    }

    override func tearDown() {
        storage.reset()
    }
}
```

---

### Face ID / Touch ID authentication

`LocalAuthenticationManager` wraps `LAContext` with a clean callback API, adapts automatically to Face ID, Touch ID, Optic ID, or passcode, and evaluates against `.deviceOwnerAuthentication` (biometrics + passcode fallback).

```swift
final class LockScreenViewModel {
    private let auth = LocalAuthenticationManager(reason: "Verify your identity to continue.")

    func unlock() {
        guard auth.canAuthenticate else {
            view?.showPasscodeEntry()
            return
        }
        auth.authenticate { [weak self] success in
            // already dispatched to main thread
            success ? self?.view?.unlockApp() : self?.view?.showError()
        }
    }

    func authLabel() -> String {
        switch auth.localAuthenticationType {
        case .biometry(.faceId):  return "Unlock with Face ID"
        case .biometry(.touchId): return "Unlock with Touch ID"
        case .passcode:           return "Enter Passcode"
        case .none:               return "Authentication unavailable"
        default:                  return "Unlock"
        }
    }
}
```

---

### Sign in with Apple

`AppleLoginManager` handles the full `ASAuthorizationController` flow and decodes the identity token JWT, returning credentials and the decoded payload in one callback.

```swift
final class LoginCoordinator: BaseCoordinator {
    // Must be retained for the duration of the flow
    private let appleLogin = AppleLoginManager()

    func startAppleLogin(from vc: UIViewController) {
        appleLogin.performLogin(from: vc) { [weak self] result in
            switch result {
            case .success(let (credential, token)):
                let userId    = credential.user
                let email     = credential.email
                let givenName = credential.fullName?.givenName
                let sub       = token["sub"] as? String
                self?.finishLogin(userId: userId, email: email)

            case .failure(let error):
                self?.view?.showError(error.localizedDescription)
            }
        }
    }
}
```

---

### Feedback UI

**Snackbar** — slides in from the bottom, auto-dismisses:

```swift
Snackbar.show(Snackbar.ViewModel(message: "Profile updated successfully."))

// With an action button:
Snackbar.show(Snackbar.ViewModel(
    message: "Message sent.",
    actionTitle: "Undo",
    onAction: { self.undoSend() }
))
```

**Toast** — brief overlay in the center of the screen:

```swift
Toast.present(with: "Copied to clipboard")
```

**Custom modal alert** — compose any content view and present it as a dismissible overlay. The closure fires when the backdrop or any dismiss-triggering control is tapped.

```swift
let alert = CustomAlertWireframe.createModule(
    VStack(alignment: .center, margins: .init(all: 24), spacing: 16) {
        UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            .tintColor(.systemGreen).set(width: 56).setRatio()

        UILabel("Payment sent!")
            .font(.boldSystemFont(ofSize: 22)).textAlignment(.center)

        UILabel("Your transfer of $120 is on its way.")
            .font(.systemFont(ofSize: 15)).textColor(.secondaryLabel)
            .textAlignment(.center).numberOfLines()

        UIButton(configuration: .filled()
            .attributedTitle(.init("Done"))
            .baseBackgroundColor(.systemBlue)
            .cornerStyle(.capsule)
        ).onTap { [weak self] in self?.dismiss() }.setRatio(280 / 48)
    }
    .backgroundColor(.systemBackground).setAsRoundedView(radius: 20)
) { [weak self] in self?.dismiss() }

present(.overCurrent, viewController: alert)
```

---

### Debounced input

Prevent redundant network calls or heavy operations while a user is typing. `Debouncer` coalesces rapid calls into one, firing only after the quiet period.

```swift
// In a UITextFieldDelegate or onChange handler:
func searchFieldChanged(text: String) {
    Debouncer.debounce(from: #function, seconds: 0.35) { [weak self] in
        self?.viewModel.search(query: text)
    }
}
```

Multiple independent debouncers in the same caller — use `id:`:

```swift
Debouncer.debounce(from: #function, id: "username", seconds: 0.3) { self.validateUsername(text) }
Debouncer.debounce(from: #function, id: "email",    seconds: 0.3) { self.validateEmail(text) }
```

---

### AES encryption

Encrypt and decrypt strings or raw `Data` with AES-128 or AES-256 in CBC mode (PKCS7 padding). Key must be exactly 16 or 32 characters; IV must be exactly 16 characters.

```swift
let aes = AES(key: "your-16-or-32-ch", iv: "your-16-char-iv!")

// Encrypt a string → Data
let encrypted: Data? = aes?.encrypt("sensitive data")

// Encrypt raw Data
let encryptedData: Data? = aes?.encrypt(someData)

// Decrypt back to string
if let encrypted,
   let decrypted = aes?.decrypt(encrypted),
   let text = String(data: decrypted, encoding: .utf8) {
    print(text) // "sensitive data"
}
```

---

## Local Development

The Xcode project is generated from `project.yml` using [XcodeGen](https://github.com/yonaskolb/XcodeGen) and is not committed to source control.

```bash
brew install xcodegen
xcodegen generate
open Common.xcodeproj
```

Re-run `xcodegen generate` (or `make generate`) whenever `project.yml` changes.

**Build commands:**

```bash
make generate             # Regenerate Common.xcodeproj
make build_xcframework    # Build Common.xcframework (device + simulator)
make patch                # Tag and release a patch version
make minor                # Tag and release a minor version
make major                # Tag and release a major version
```

---

## Demo App

The project includes a `DemoApp` target that showcases the library across 14 modules: Alerts, Coordinator, Declarative UI, Extensions, Forms & TextFields, Home, Image Loading, Lists & Cells, Local Auth, Networking, Onboarding, Storage, Typography, and Utilities. Build and run the `DemoApp` scheme in Xcode to explore.

---

## Documentation

The codebase is fully documented with DocC comments. Generate HTML documentation with [Jazzy](https://github.com/realm/jazzy):

```bash
jazzy
```

Output is at `docs/index.html`. Documentation is also published automatically to GitHub Pages on every push to `main`.

---

## Versioning

This project uses [Semantic Versioning](https://semver.org/). Use the release script from `main`:

```bash
./release.sh patch   # 1.2.3 → 1.2.4
./release.sh minor   # 1.2.3 → 1.3.0
./release.sh major   # 1.2.3 → 2.0.0
```

---

## License

See [LICENSE](LICENSE) for details.
