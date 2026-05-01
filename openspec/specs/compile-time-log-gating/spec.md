## ADDED Requirements

### Requirement: Logger exposes a compile-time enabled constant
`Logger` SHALL expose `public static let isCompileTimeEnabled: Bool` that is `true` in `DEBUG` builds and `false` in all other build configurations.

#### Scenario: Release build constant is false
- **WHEN** the framework is compiled without the `DEBUG` Swift compiler flag
- **THEN** `Logger.isCompileTimeEnabled` equals `false`

#### Scenario: Debug build constant is true
- **WHEN** the framework is compiled with the `DEBUG` Swift compiler flag
- **THEN** `Logger.isCompileTimeEnabled` equals `true`

### Requirement: shouldLog returns false immediately in release builds
`Loggable.shouldLog` getter SHALL return `false` without accessing `_loggableCache` or `_loggableStore` when `Logger.isCompileTimeEnabled` is `false`.

#### Scenario: No Keychain access on shouldLog read in release
- **WHEN** `AnyType.shouldLog` is read in a release build
- **THEN** no Keychain API is called and `false` is returned immediately

#### Scenario: No cache access on shouldLog read in release
- **WHEN** `AnyType.shouldLog` is read multiple times in a release build
- **THEN** `_loggableCache` is never read or written

#### Scenario: Logger.log is a no-op in release
- **WHEN** `Logger.log(["key": "value"])` is called in a release build
- **THEN** nothing is printed to the console and no side effects occur

### Requirement: Compile-time constant enables dead-code elimination
Because `Logger.isCompileTimeEnabled` is a `let` constant, the Swift compiler SHALL eliminate unreachable logging branches in release builds (e.g. `if shouldLog { … }` blocks in HTTPService become dead code and are stripped from the binary).

#### Scenario: Release binary contains no Logger print calls from framework
- **WHEN** the `Common` framework is compiled in release and inspected for logging symbols
- **THEN** the logging code paths in `HTTPService`, `BaseViewController`, and `BaseCoordinator` are absent from the compiled output

### Requirement: Logger.forceEnable() is available in DEBUG builds only
`Logger` SHALL provide `public static func forceEnable()` under `#if DEBUG` that sets `Logger.shouldLog = true`, enabling framework logs for the duration of the process.

#### Scenario: forceEnable is callable in DEBUG
- **WHEN** `Logger.forceEnable()` is called in a DEBUG build
- **THEN** subsequent `Logger.log` calls produce console output

#### Scenario: forceEnable does not exist in release builds
- **WHEN** code calls `Logger.forceEnable()` and is compiled without the `DEBUG` flag
- **THEN** the compiler emits an error (symbol does not exist in release)
