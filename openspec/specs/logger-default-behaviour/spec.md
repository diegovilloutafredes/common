## MODIFIED Requirements

### Requirement: shouldLog defaults to false in non-DEBUG builds
`Loggable.shouldLog` SHALL return `false` by default (when no value has been explicitly set via the setter) in non-`DEBUG` build configurations. In `DEBUG` builds it SHALL continue to default to `true`.

#### Scenario: Release build with no prior setter call
- **WHEN** `AnyType.shouldLog` is read in a release build with no Keychain entry for that type
- **THEN** it returns `false`

#### Scenario: Debug build with no prior setter call
- **WHEN** `AnyType.shouldLog` is read in a DEBUG build with no Keychain entry for that type
- **THEN** it returns `true` (unchanged from current behaviour)

#### Scenario: Explicit setter overrides default in DEBUG
- **WHEN** `HTTPService.shouldLog = false` is called in a DEBUG build
- **THEN** subsequent reads of `HTTPService.shouldLog` return `false`

#### Scenario: Setter has no observable effect in release
- **WHEN** `HTTPService.shouldLog = true` is called in a release build
- **THEN** `HTTPService.shouldLog` still returns `false` (compile-time gate takes precedence)

### Requirement: Lifecycle log calls produce no output in release
`BaseViewController` and `BaseViewModelableViewController` lifecycle overrides (`viewDidLoad`, `viewWillAppear`, `viewIsAppearing`, `viewDidAppear`, `viewWillDisappear`, `viewDidDisappear`) SHALL produce no console output in release builds.

#### Scenario: Screen transition in release build
- **WHEN** a screen is pushed and the full lifecycle fires in a release build
- **THEN** zero lines are printed to the console from the framework lifecycle methods

#### Scenario: Screen transition in debug build
- **WHEN** a screen is pushed and the full lifecycle fires in a DEBUG build
- **THEN** each lifecycle event emits a log entry to the console as before

### Requirement: Network request logs produce no output in release
`HTTPService` `if shouldLog { Logger.log(…) }` branches SHALL produce no console output in release builds.

#### Scenario: Network request in release build
- **WHEN** an HTTP request completes successfully in a release build
- **THEN** no request URL, headers, response body, or timing delta is printed to the console

#### Scenario: Network request in debug build
- **WHEN** an HTTP request completes in a DEBUG build
- **THEN** the request and response details are logged as before
