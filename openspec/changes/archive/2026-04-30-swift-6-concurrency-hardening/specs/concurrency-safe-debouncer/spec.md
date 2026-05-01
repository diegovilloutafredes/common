## ADDED Requirements

### Requirement: Debouncer is safe to call from any thread
The system SHALL guarantee that concurrent calls to `Debouncer.debounce(from:id:seconds:function:)` from different threads never produce a data race on the internal timer dictionary.

#### Scenario: Concurrent debounce calls from multiple threads
- **WHEN** two threads simultaneously call `Debouncer.debounce` with different keys
- **THEN** both timers are created without corrupting each other and both callbacks fire independently

#### Scenario: Concurrent debounce calls with the same key from two threads
- **WHEN** two threads simultaneously call `Debouncer.debounce` with the same key
- **THEN** only one timer survives (the later one wins) and the callback fires exactly once after the delay

### Requirement: Debouncer callback fires on the main thread
The debounced `function` closure SHALL be called on the main thread, matching the existing `RunLoop.main` scheduling behaviour.

#### Scenario: Callback thread
- **WHEN** `Debouncer.debounce(seconds:function:)` fires after its delay
- **THEN** `Thread.isMainThread` is `true` inside the `function` closure

### Requirement: Debouncer public API is unchanged
The static method `Debouncer.debounce(from:id:seconds:function:)` SHALL remain callable from synchronous (non-async) Swift code without changes at the call site.

#### Scenario: Existing call site compiles without modification
- **WHEN** existing code calls `Debouncer.debounce(from: #function, seconds: 0.3) { ... }`
- **THEN** the code compiles and behaves identically to before
