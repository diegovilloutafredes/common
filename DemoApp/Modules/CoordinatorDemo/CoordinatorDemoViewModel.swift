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

// MARK: - CoordinatorDemoViewModelDelegate

protocol CoordinatorDemoViewModelDelegate: AnyObject {
    func didRequestLaunchChild()
    func didRequestLaunchDeepFlow()
    func didRequestPresentSheet()
    func didRequestStatsRefresh()
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

/// The coordinator writes stats and events into this observable model; the controller
/// renders them in `updateContent()`. No view protocol is needed.
@Observable
@MainActor
final class CoordinatorDemoViewModel: CoordinatorDemoViewModelProtocol {
    private(set) var children: Int = .zero
    private(set) var navStack: Int = .zero
    private(set) var eventCount: Int = .zero
    private(set) var events: [CoordinatorEvent] = []

    @ObservationIgnored private weak var delegate: CoordinatorDemoViewModelDelegate?

    init(delegate: CoordinatorDemoViewModelDelegate) {
        self.delegate = delegate
    }

    func launchChild() { delegate?.didRequestLaunchChild() }
    func launchDeepFlow() { delegate?.didRequestLaunchDeepFlow() }
    func presentSheet() { delegate?.didRequestPresentSheet() }
    func requestStatsRefresh() { delegate?.didRequestStatsRefresh() }

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
