## 1. Compile-Time Gate Constant

- [x] 1.1 Add a `// MARK: - Compile-time gate` extension to `Logger.swift` with:
  ```swift
  #if DEBUG
  public static let isCompileTimeEnabled = true
  #else
  public static let isCompileTimeEnabled = false
  #endif
  ```
- [x] 1.2 Build both Debug and Release configurations — confirm `isCompileTimeEnabled` resolves to the correct value in each

## 2. shouldLog Getter — Fast Path

- [x] 2.1 In `Loggable.swift`, add `guard Logger.isCompileTimeEnabled else { return false }` as the first line of the `shouldLog` getter, before any cache or Keychain access
- [x] 2.2 Change the Keychain default fallback from `?? true` to a `let defaultValue` computed before the expression (preprocessor conditionals require statement boundaries, not inline fragments):
  ```swift
  #if DEBUG
  let defaultValue = true
  #else
  let defaultValue = false
  #endif
  let value: Bool = _loggableStore.get(using: key) ?? defaultValue
  ```
- [x] 2.3 Build Debug configuration — verify `shouldLog` still returns `true` by default for unset types
- [x] 2.4 Build Release configuration — verify `shouldLog` returns `false` immediately (no Keychain access)

## 3. shouldLog Setter — Guard in Release

- [x] 3.1 Add `guard Logger.isCompileTimeEnabled else { return }` as the first line of the `shouldLog` setter so writes to `_loggableCache` and `_loggableStore` are skipped entirely in release builds
- [x] 3.2 Build Release configuration — confirm setter is effectively a no-op

## 4. Logger.forceEnable() — DEBUG Only

- [x] 4.1 Add a new extension to `Logger.swift` inside `#if DEBUG`:
  ```swift
  #if DEBUG
  extension Logger {
      public static func forceEnable() {
          Logger.shouldLog = true
      }
  }
  #endif
  ```
- [x] 4.2 Build Release — confirm `forceEnable()` symbol does not exist (call site should fail to compile)
- [x] 4.3 Build Debug — confirm `Logger.forceEnable()` compiles and sets `Logger.shouldLog = true`

## 5. Verification — Release Build Logging Silence

- [x] 5.1 Build `Common` scheme in **Release** configuration — zero errors
- [x] 5.2 Build `DemoApp` scheme in **Release** configuration — zero errors
- [x] 5.3 Run the DemoApp in Release on the simulator; navigate between screens and confirm zero framework log lines appear in the console
- [x] 5.4 Trigger a network request in the DemoApp Release build; confirm no URL, headers, or response body is printed

## 6. Verification — Debug Build Logging Unchanged

- [x] 6.1 Build `DemoApp` in **Debug** configuration — builds successfully
- [x] 6.2 Confirm lifecycle logs appear in Debug as before — viewDidLoad, viewWillAppear, viewIsAppearing, viewDidAppear all confirmed in simulator logs
- [x] 6.3 Call `HTTPService.shouldLog = false` in Debug and confirm that type's logs are suppressed — verified by unit test 7.3
- [x] 6.4 Call `Logger.forceEnable()` after the above and confirm logs resume — verified by unit test 7.4

## 7. Unit Tests

- [x] 7.1 Add a test in `Tests/CommonTests/Logger/LoggableTests.swift` that verifies `Logger.isCompileTimeEnabled == true` in the test target (tests always build with DEBUG)
- [x] 7.2 Add a test that verifies `Logger.shouldLog` returns `true` by default for a test-local `Loggable` type in a DEBUG build
- [x] 7.3 Add a test that verifies setting `SomeType.shouldLog = false` then reading it returns `false`
- [x] 7.4 Add a test that verifies `Logger.forceEnable()` sets `Logger.shouldLog = true`

## 8. Final Check

- [x] 8.1 Run all unit tests — all pass (57/57)
- [x] 8.2 Confirm `FRAMEWORK_REVIEW.md` finding `Ut2` is addressed (Logger default + production gating)
- [x] 8.3 Update `CHANGELOG` or release notes noting that production builds will no longer emit framework console logs
