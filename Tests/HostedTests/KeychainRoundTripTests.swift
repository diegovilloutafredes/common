//
//  KeychainRoundTripTests.swift
//
//  Hosted lane: this bundle is injected into DemoApp (TEST_HOST), where the
//  simulator Keychain actually works. The hostless CommonTests suites tolerate
//  nil reads because SecItem silently returns nothing there — here a nil read
//  for a just-written key is a FAILURE. This is the lane where a
//  KeychainWrapper read regression turns red (audit item 5).
//

import XCTest
import Common

final class KeychainRoundTripTests: XCTestCase {

    /// Dedicated namespace so these tests can clean up after themselves
    /// without touching other suites' keys (e.g. Loggable's shouldLog keys).
    private let namespace = "hosted-tests."
    private var keychain: KeychainWrapper { .standard }

    private func key(_ name: String) -> String { namespace + name }

    /// GitHub-hosted runners have no signing identity for the DemoApp host, and
    /// there every SecItem call returns nothing — all seven round-trips fail
    /// identically. Skip there, loudly; the strict lane runs locally via `make ci`.
    override func setUpWithError() throws {
        try super.setUpWithError()
        try XCTSkipIf(
            ProcessInfo.processInfo.environment["GITHUB_ACTIONS"] == "true",
            "Simulator Keychain is unavailable to the test host on GitHub-hosted runners; run `make ci` locally for the strict lane."
        )
    }

    override func tearDown() {
        keychain.allKeys()
            .filter { $0.hasPrefix(namespace) }
            .forEach { keychain.removeObject(forKey: $0) }
        super.tearDown()
    }

    // MARK: - KeychainWrapper round-trips (strict)

    func test_string_roundTrips() {
        XCTAssertTrue(keychain.set("secret-value", forKey: key("string")), "keychain write must succeed in the hosted lane")

        XCTAssertEqual(keychain.string(forKey: key("string")), "secret-value",
                       "a just-written string must read back — nil here is the read regression this lane exists to catch")
    }

    func test_data_roundTrips() {
        let payload = Data([0x01, 0x02, 0x03, 0xFF])
        XCTAssertTrue(keychain.set(payload, forKey: key("data")))

        XCTAssertEqual(keychain.data(forKey: key("data")), payload)
    }

    func test_bool_and_numeric_roundTrip() {
        XCTAssertTrue(keychain.set(true, forKey: key("bool")))
        XCTAssertTrue(keychain.set(42, forKey: key("int")))
        XCTAssertTrue(keychain.set(3.5, forKey: key("double")))

        XCTAssertEqual(keychain.bool(forKey: key("bool")), true)
        XCTAssertEqual(keychain.integer(forKey: key("int")), 42)
        XCTAssertEqual(keychain.double(forKey: key("double")), 3.5)
    }

    func test_overwrite_returnsNewValue() {
        keychain.set("first", forKey: key("overwrite"))

        XCTAssertTrue(keychain.set("second", forKey: key("overwrite")), "overwriting an existing key must succeed")
        XCTAssertEqual(keychain.string(forKey: key("overwrite")), "second")
    }

    func test_remove_deletesValue() {
        keychain.set("doomed", forKey: key("remove"))
        XCTAssertTrue(keychain.hasValue(forKey: key("remove")), "precondition: value present before removal")

        XCTAssertTrue(keychain.removeObject(forKey: key("remove")))

        XCTAssertNil(keychain.string(forKey: key("remove")), "a removed key must read nil")
        XCTAssertFalse(keychain.hasValue(forKey: key("remove")))
    }

    func test_hasValue_reflectsPresence() {
        XCTAssertFalse(keychain.hasValue(forKey: key("never-written")))

        keychain.set("here", forKey: key("present"))

        XCTAssertTrue(keychain.hasValue(forKey: key("present")))
    }

    // MARK: - KeyValueStore(.secure) round-trip (strict)

    private struct Token: Storable, Equatable {
        let value: String
        let issuedAt: Date
    }

    func test_secureKeyValueStore_roundTrips() {
        let store = KeyValueStore(type: .secure)
        let token = Token(value: "abc-123", issuedAt: Date(timeIntervalSince1970: 1_000_000))

        store.add(item: (key("token"), token))
        let read: Token? = store.get(using: key("token"))

        XCTAssertEqual(read, token, "a Storable written through the secure store must decode back identically")

        store.remove(using: key("token"))
        let afterRemove: Token? = store.get(using: key("token"))
        XCTAssertNil(afterRemove)
    }
}
