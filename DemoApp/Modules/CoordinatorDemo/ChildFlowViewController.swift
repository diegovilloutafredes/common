//
//  ChildFlowViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ChildFlowViewController

final class ChildFlowViewController: UIViewController {
    var onComplete: (() -> Void)?
    var onCancel: (() -> Void)?
    var onGoDeeper: (() -> Void)?

    private let depth: Int
    private let maxDepth: Int

    init(depth: Int, maxDepth: Int) {
        self.depth = depth
        self.maxDepth = maxDepth
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Stat Labels

    private lazy var depthValueLabel = UILabel("\(depth)")
        .font(.systemFont(ofSize: 28, weight: .bold))
        .textAlignment(.center)
        .with { $0.accessibilityIdentifier = "childStat.depth" }

    private lazy var navStackValueLabel = UILabel("–")
        .font(.systemFont(ofSize: 28, weight: .bold))
        .textAlignment(.center)
        .with { $0.accessibilityIdentifier = "childStat.navStack" }

    private lazy var remainingValueLabel = UILabel("\(maxDepth - depth)")
        .font(.systemFont(ofSize: 28, weight: .bold))
        .textAlignment(.center)
        .with { $0.accessibilityIdentifier = "childStat.remaining" }

    // MARK: - Buttons

    private lazy var completeButton = UIButton(
        configuration: .filled().with {
            $0.title = "Complete"
            $0.cornerStyle = .capsule
            $0.image = UIImage(systemName: "checkmark.circle.fill")
            $0.imagePadding = 6
        }
    )
    .onTap { [weak self] in self?.onComplete?() }
    .setConstraints { $0.set(height: 48) }

    private lazy var goDeeperButton = UIButton(
        configuration: .tinted().with {
            $0.title = "Go Deeper"
            $0.cornerStyle = .capsule
            $0.image = UIImage(systemName: "arrow.down.circle.fill")
            $0.imagePadding = 6
        }
    )
    .onTap { [weak self] in self?.onGoDeeper?() }
    .setConstraints { $0.set(height: 48) }
    .isHidden(depth >= maxDepth)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = titleFor(depth: depth)
        view.backgroundColor(.systemBackground)
        buildUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navStackValueLabel.text("\(navigationController?.viewControllers.count ?? 0)")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent { onCancel?() }
    }

    // MARK: - UI

    private func buildUI() {
        let statsRow = HStack(distribution: .fillEqually, spacing: 8) {
            makeStatCard(valueLabel: depthValueLabel, key: "Depth")
            makeStatCard(valueLabel: navStackValueLabel, key: "Nav Stack")
            makeStatCard(valueLabel: remainingValueLabel, key: "Remaining")
        }

        let container = VStack(
            alignment: .fill,
            margins: .init(top: 24, left: 16, bottom: 24, right: 16),
            spacing: 16
        ) {
            statsRow
            completeButton
            goDeeperButton
        }

        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func makeStatCard(valueLabel: UILabel, key: String) -> UIView {
        VStack(alignment: .center, margins: .init(all: 12), spacing: 2) {
            valueLabel
            UILabel(key)
                .font(.systemFont(ofSize: 11))
                .textColor(.secondaryLabel)
                .textAlignment(.center)
        }
        .backgroundColor(.secondarySystemBackground)
        .setAsRoundedView(radius: 10)
    }

    private func titleFor(depth: Int) -> String {
        switch depth {
        case 1: return "Child Flow"
        case 2: return "Nested Flow"
        default: return "Deep Flow"
        }
    }
}
