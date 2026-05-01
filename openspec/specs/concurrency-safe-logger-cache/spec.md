## ADDED Requirements

### Requirement: Logging flag cache is thread-safe
The `Loggable.shouldLog` getter and setter SHALL be safe to call concurrently from multiple threads without producing a data race on the internal cache dictionary.

#### Scenario: Concurrent reads from different threads
- **WHEN** two background threads simultaneously read `SomeType.shouldLog` for the first time
- **THEN** both receive a valid `Bool` and no crash or data corruption occurs

#### Scenario: Concurrent read and write
- **WHEN** one thread writes `SomeType.shouldLog = false` while another is reading `SomeType.shouldLog`
- **THEN** the read returns either the old or new value atomically — never a torn read

### Requirement: Logging flag default remains `true` when unset
`Loggable.shouldLog` SHALL return `true` when no value has been persisted, preserving the existing default behaviour.

#### Scenario: First access on a new install
- **WHEN** `SomeType.shouldLog` is read before any value is written
- **THEN** it returns `true`

### Requirement: Logging flag persists across process launches
Once `SomeType.shouldLog = false` is written, subsequent process launches SHALL reflect that value without requiring it to be set again.

#### Scenario: Persistence across launch
- **WHEN** `SomeType.shouldLog = false` is set and the app is restarted
- **THEN** `SomeType.shouldLog` returns `false` on the next launch
