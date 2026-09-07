//
//  CoordinatorDemoViewModel.swift
//  DemoApp
//

import Common
import Foundation
import Observation

// MARK: - CoordinatorEvent

struct CoordinatorEvent {
    let icon: String
    let message: String
    let delta: Int
    let time: Date = .init()
}

// MARK: - CoordinatorDemoViewModelProtocol

@MainActor
protocol CoordinatorDemoViewModelProtocol: ViewModel {
    var children: Int { get }
    var navStack: Int { get }
    var eventCount: Int { get }
    /// Newest first.
    var events: [CoordinatorEvent] { get }
    func launchChild()
    func launchDeepFlow()
    func presentSheet()
    func requestStatsRefresh()
}

// MARK: - CoordinatorDemoViewModel

/// The coordinator writes stats and events into this observable model (an input, like any
/// other data source); the controller renders them in `updateContent()`. Requests go out
/// through `onRequested`; nothing here points back at the controller or the coordinator.
@Observable
@MainActor
final class CoordinatorDemoViewModel: CoordinatorDemoViewModelProtocol {
    /// Flows and modals the coordinator starts, plus a stats refresh only it can answer.
    enum Requested { case launchChild, launchDeepFlow, presentSheet, refreshStats }

    private(set) var children: Int = .zero
    private(set) var navStack: Int = .zero
    private(set) var eventCount: Int = .zero
    private(set) var events: [CoordinatorEvent] = []

    @ObservationIgnored private let onRequested: Handler<Requested>

    init(onRequested: @escaping Handler<Requested>) {
        self.onRequested = onRequested
    }

    func launchChild() { onRequested(.launchChild) }
    func launchDeepFlow() { onRequested(.launchDeepFlow) }
    func presentSheet() { onRequested(.presentSheet) }
    func requestStatsRefresh() { onRequested(.refreshStats) }

    func logAndRefresh(_ event: CoordinatorEvent, children: Int, navStack: Int) {
        events.insert(event, at: .zero)
        eventCount += 1
        refreshStats(children: children, navStack: navStack)
    }

    func refreshStats(children: Int, navStack: Int) {
        // Observation fires on every assignment, so only write what actually changed.
        if self.children != children { self.children = children }
        if self.navStack != navStack { self.navStack = navStack }
    }
}
