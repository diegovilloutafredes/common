# Network Layer Rewrite Proposal

**Status:** Proposed — awaiting decision
**Created:** 2026-05-05
**Context:** Surfaced while running periphery on `Libraries/common`. Several files in the network layer (`URLEncodedFormEncoder`, `HTTPHeaders`, the `ParameterEncoder` protocol family) appear to be unattributed ports of Alamofire 5 source. The visible AF naming markers were removed (commit pending), but the structural lineage and licensing concern remain.

---

## What's genuinely ours vs. ported

### Ours — keep
These are the actual architecture. None resemble Alamofire.

- `BaseClient` / `AsyncBaseClient` — client base classes with in-flight task tracking
- `HTTPService` / `HTTPService+Async` — request executor + async/await overloads
- `Endpoint` / `URLRequestConvertible` — endpoint protocol layer
- `MultipartRequest` — multipart form construction
- `NetworkError` — domain error type
- `Environment` — base URL / environment abstraction
- `HTTPMethod` — enum

### Ported — rethink targets

| File | Approx. lines | Notes |
|---|---|---|
| `Common/Network/Encoders/URLEncodedFormEncoder.swift` | ~990 | Heaviest port. 6 of 7 configuration knobs are unexercised in production (periphery confirmed `dots`, `dropValue`, `null`, `localizedDescription`, `init(_:)` unused; the only `AF`-prefixed surface marker, `afURLQueryAllowed`, was already removed). |
| `Common/Network/HTTPHeaders.swift` | ~400 | Order-preserving, case-insensitive `HTTPHeaders` struct + `HTTPHeader` with `static func accept(_:)`-style factories. Verbatim from Alamofire. |
| `Common/Network/Encoders/Parameters/ParameterEncoder.swift` + `JSONParameterEncoder.swift` + `URLEncodedFormParameterEncoder.swift` | ~150 combined | Protocol layer wrapping the encoders. The two concrete classes are constructed directly at `Endpoint.swift:81-82`; the protocol is not used as an existential or generic constraint anywhere. |

---

## Recommendation

**Replace the encoder layer with Foundation primitives, keep everything else.**

- **`URLEncodedFormEncoder` →** `URLComponents.queryItems` + a small helper that maps an `Encodable` to `[URLQueryItem]` via a `JSONEncoder` → `[String: Any]` round-trip. Foundation handles the percent-escaping and standard cases.
- **`JSONEncoder` direct for bodies** — drop the `JSONParameterEncoder` wrapper; use the stdlib type with `request.httpBody = try JSONEncoder().encode(parameters)`.
- **`HTTPHeaders` →** plain `[String: String]`, which `URLRequest.allHTTPHeaderFields` already takes. Replace `HTTPHeader.accept(_:)`-style factories with either string constants or a small enum (e.g. `enum HeaderName { static let accept = "Accept" }`).
- **`Endpoint`** keeps the same shape; only its `headers` and `parameters` associated/property types change.

---

## Main tradeoff

You **lose** configurability that production isn't exercising:

- Custom array-bracket encoding strategies (`.brackets` vs `.indexInBrackets` vs custom)
- Numeric vs literal bool encoding
- Base64 vs deferred data encoding
- Custom date strategies beyond `JSONEncoder`'s built-ins
- Case-insensitive header dedup and ordering preservation

You **gain**:

- ~1,300 lines of ported code removed
- License-attribution concern resolved (no derivative work to disclose)
- Foundation's bug fixes and security updates inherited
- Smaller surface area to maintain

For a typical REST consumer (which all the in-tree consumers — UniPay, bioidentity-v3, the DemoApp — are), Foundation primitives + the existing `Endpoint` layer cover the actual usage.

---

## Compatibility considerations

- The `Endpoint.swift:81-82` call sites construct encoders concretely with default constructors. The cutover inside `Common` is a single-file change if `Endpoint`'s associated types change.
- **SPM consumers (UniPay) would need a coordinated bump** because the public types referenced in their `Endpoint` conformances change. This is a breaking change for consumers, so it should be sequenced as a minor/major version bump per the semver discipline in `Libraries/common/CLAUDE.md`.
- The bioidentity-v3 vendored fork already has its own copy of the same files — it's not affected by changes here.

---

## Open decisions

Pick one (or sequence them):

1. **Sketch the smaller versions of these files in more detail** before deciding — produces a concrete proposed diff to evaluate against.
2. **Prototype just the `URLEncodedFormEncoder` replacement first** — biggest win (~990 lines), smallest blast radius, validates the approach.
3. **Leave it as-is and add MIT attribution headers** to the ported files — minimum-effort path that resolves only the license concern, not the maintenance burden.
4. **Do nothing** — accept the status quo and revisit later.

The default if no choice is made: option 4. The license concern persists until either (2) or (3) is acted on.
