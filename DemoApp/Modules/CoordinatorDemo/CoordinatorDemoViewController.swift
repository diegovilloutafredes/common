//
//  CoordinatorDemoViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - CoordinatorDemoStatus

enum CoordinatorDemoStatus: String {
    case idle = "Idle"
    case childRunning = "Child Running"
    case finished = "Finished"
    case cancelled = "Cancelled"

    var detail: String {
        switch self {
        case .idle:         return "Tap the button to launch a child coordinator flow"
        case .childRunning: return "Child coordinator is active — swipe back to cancel, or complete the flow"
        case .finished:     return "finish() was called — onPerformed fired ✓"
        case .cancelled:    return "Back gesture detected — cancel() fired, onPerformed skipped ✗"
        }
    }
}

// MARK: - CoordinatorDemoViewProtocol

protocol CoordinatorDemoViewProtocol: AnyObject {
    func setStatus(_ status: CoordinatorDemoStatus)
}

// MARK: - CoordinatorDemoViewModelDelegate

protocol CoordinatorDemoViewModelDelegate: AnyObject {
    func coordinatorDemoDidRequestLaunch()
}

// MARK: - CoordinatorDemoViewModelProtocol

protocol CoordinatorDemoViewModelProtocol: ViewModel {
    func launchChild()
}

// MARK: - CoordinatorDemoViewModel

final class CoordinatorDemoViewModel: CoordinatorDemoViewModelProtocol {
    weak var view: CoordinatorDemoViewProtocol?
    weak var delegate: CoordinatorDemoViewModelDelegate?

    func launchChild() {
        delegate?.coordinatorDemoDidRequestLaunch()
    }

    func setStatus(_ status: CoordinatorDemoStatus) {
        view?.setStatus(status)
    }
}

// MARK: - CoordinatorDemoViewController

final class CoordinatorDemoViewController: BaseViewModelableViewController<CoordinatorDemoViewModelProtocol> {

    private lazy var statusLabel = UILabel()
        .font(.systemFont(ofSize: 32, weight: .bold))
        .textAlignment(.center)
        .numberOfLines(1)

    private lazy var detailLabel = UILabel()
        .font(.systemFont(ofSize: 14))
        .textColor(.secondaryLabel)
        .textAlignment(.center)
        .numberOfLines(0)

    private lazy var launchButton = UIButton(
        configuration: .filled().with {
            $0.title = "Launch Child Flow"
            $0.cornerStyle = .capsule
            $0.image = UIImage(systemName: "arrow.right.circle")
            $0.imagePadding = 6
        }
    )
    .onTap { [weak self] in self?.viewModel.launchChild() }
    .setConstraints { $0.set(height: 44) }

    @UIViewBuilder override var mainView: UIView {
        VStack(
            alignment: .center,
            margins: .init(top: 48, left: 24, bottom: 24, right: 24),
            spacing: 16
        ) {
            statusLabel
            detailLabel
            launchButton
        }
        .setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        title = "Coordinator Demo"
        view.backgroundColor(.systemBackground)
        setStatus(.idle)
    }
}

// MARK: - CoordinatorDemoViewProtocol

extension CoordinatorDemoViewController: CoordinatorDemoViewProtocol {
    func setStatus(_ status: CoordinatorDemoStatus) {
        statusLabel.text(status.rawValue)
        detailLabel.text(status.detail)
        launchButton.isEnabled = status != .childRunning
    }
}
