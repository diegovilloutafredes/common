//
//  LocationAuthorizationManagerTests.swift
//

import CoreLocation
import XCTest
@testable import Common

/// `request(_:handler:)` answers once per request. Core Location is replaced by a subclass whose status the test sets;
/// its reports are simulated by calling the delegate method.
@MainActor
final class LocationAuthorizationManagerTests: XCTestCase {

    private final class FakeLocationManager: CLLocationManager {
        var status: CLAuthorizationStatus = .notDetermined
        private(set) var requests: [String] = []
        override var authorizationStatus: CLAuthorizationStatus { status }
        override func requestWhenInUseAuthorization() { requests.append("whenInUse") }
        override func requestAlwaysAuthorization() { requests.append("always") }
    }

    private let fake = FakeLocationManager()
    private lazy var manager = LocationAuthorizationManager(locationManager: fake)

    /// Simulates Core Location reporting `status` to the delegate.
    private func report(_ status: CLAuthorizationStatus) {
        fake.status = status
        manager.locationManagerDidChangeAuthorization(fake)
    }

    /// The defect: a request made once the user had decided waited for a report that Core Location never makes.
    func test_determinedStatus_isAnsweredRightAway_andTheRequestIsStillForwarded() {
        fake.status = .authorizedWhenInUse
        var answers: [AuthorizationStatus] = []

        manager.request(.always) { answers.append($0) }

        XCTAssertEqual(answers, [.authorized])
        XCTAssertEqual(fake.requests, ["always"], "forwarded, so the upgrade prompt can still appear")
    }

    /// The defect: the not-determined report Core Location makes when the manager is created answered the request.
    func test_undeterminedStatus_isAnsweredWithTheFirstDecisionOnly() {
        var answers: [AuthorizationStatus] = []
        manager.request(.whenInUse) { answers.append($0) }

        report(.notDetermined)
        XCTAssertEqual(answers, [], "a not-determined report must not answer")

        report(.authorizedWhenInUse)
        report(.denied)
        XCTAssertEqual(answers, [.authorized], "answered once; a later change is not reported to this request")
    }

    /// The defect: a second request replaced the first one's handler, which then never answered.
    func test_concurrentRequests_areAllAnsweredOnce() {
        var first: [AuthorizationStatus] = [], second: [AuthorizationStatus] = []
        manager.request(.whenInUse) { first.append($0) }
        manager.request(.whenInUse) { second.append($0) }

        report(.denied)

        XCTAssertEqual(first, [.denied])
        XCTAssertEqual(second, [.denied])
    }

    func test_secondRequest_afterTheDecision_isAnswered() {
        manager.request(.whenInUse) { _ in }
        report(.authorizedWhenInUse)
        var answers: [AuthorizationStatus] = []

        manager.request(.whenInUse) { answers.append($0) }

        XCTAssertEqual(answers, [.authorized])
    }

    func test_requestWithoutHandler_isForwarded() {
        manager.request(.whenInUse)
        XCTAssertEqual(fake.requests, ["whenInUse"])
    }

    func test_reportOffTheMainThread_isAnsweredOnTheMainThread() {
        let answered = expectation(description: "answered")
        manager.request(.whenInUse) { _ in
            XCTAssertTrue(Thread.isMainThread)
            answered.fulfill()
        }
        fake.status = .denied

        DispatchQueue.global().async { [manager, fake] in manager.locationManagerDidChangeAuthorization(fake) }

        wait(for: [answered], timeout: callbackDeliveryTimeout)
    }
}
