//
//  CoordinatorDemoViewModel.swift
//  DemoApp
//

import Common
import Foundation

// MARK: - CoordinatorEvent

struct CoordinatorEvent {
    let icon: String
    let message: String
    let delta: Int
    let time: Date = .init()
}

// MARK: - CoordinatorDemoViewProtocol

protocol CoordinatorDemoViewProtocol: AnyObject {
    func updateStats(children: Int, navStack: Int, eventCount: Int)
    func prependEvent(_ event: CoordinatorEvent)
}

// MARK: - CoordinatorDemoViewModelDelegate

protocol CoordinatorDemoViewModelDelegate: AnyObject {
    func didRequestLaunchChild()
    func didRequestLaunchDeepFlow()
    func didRequestStatsRefresh()
}

// MARK: - CoordinatorDemoViewModelProtocol

protocol CoordinatorDemoViewModelProtocol: ViewModel {
    func launchChild()
    func launchDeepFlow()
    func requestStatsRefresh()
}

// MARK: - CoordinatorDemoViewModel

final class CoordinatorDemoViewModel: CoordinatorDemoViewModelProtocol {
    weak var view: CoordinatorDemoViewProtocol?
    private weak var delegate: CoordinatorDemoViewModelDelegate?

    private var eventCount = 0

    init(delegate: CoordinatorDemoViewModelDelegate) {
        self.delegate = delegate
    }

    func launchChild() { delegate?.didRequestLaunchChild() }
    func launchDeepFlow() { delegate?.didRequestLaunchDeepFlow() }
    func requestStatsRefresh() { delegate?.didRequestStatsRefresh() }

    func logAndRefresh(_ event: CoordinatorEvent, children: Int, navStack: Int) {
        eventCount += 1
        view?.prependEvent(event)
        view?.updateStats(children: children, navStack: navStack, eventCount: eventCount)
    }

    func refreshStats(children: Int, navStack: Int) {
        view?.updateStats(children: children, navStack: navStack, eventCount: eventCount)
    }
}
