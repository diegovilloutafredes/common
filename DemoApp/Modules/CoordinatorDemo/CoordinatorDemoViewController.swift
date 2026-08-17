//
//  CoordinatorDemoViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - CoordinatorDemoViewController

final class CoordinatorDemoViewController: BaseViewModelableViewController<CoordinatorDemoViewModelProtocol> {

    // MARK: - Stat Labels

    private lazy var childrenValueLabel = makeStatValueLabel(id: "stat.children")
    private lazy var navStackValueLabel = makeStatValueLabel(id: "stat.navStack")
    private lazy var eventsValueLabel = makeStatValueLabel(id: "stat.events")

    // MARK: - Event Log

    private lazy var eventStack = VStack(alignment: .fill, spacing: 8) {}

    // MARK: - Buttons

    private lazy var launchChildButton = UIButton(
        configuration: .filled().with {
            $0.title = "Launch Child"
            $0.cornerStyle = .capsule
            $0.image = UIImage(systemName: "arrow.right.circle.fill")
            $0.imagePadding = 6
        }
    )
    .onTap { [weak self] in self?.viewModel.launchChild() }
    .setConstraints { $0.set(height: 48) }

    private lazy var launchDeepFlowButton = UIButton(
        configuration: .tinted().with {
            $0.title = "Launch Deep Flow"
            $0.cornerStyle = .capsule
            $0.image = UIImage(systemName: "arrow.down.right.circle.fill")
            $0.imagePadding = 6
        }
    )
    .onTap { [weak self] in self?.viewModel.launchDeepFlow() }
    .setConstraints { $0.set(height: 48) }

    private lazy var presentSheetButton = UIButton(
        configuration: .gray().with {
            $0.title = "Present Sheet"
            $0.cornerStyle = .capsule
            $0.image = UIImage(systemName: "rectangle.bottomhalf.filled")
            $0.imagePadding = 6
        }
    )
    .onTap { [weak self] in self?.viewModel.presentSheet() }
    .setConstraints { $0.set(height: 48) }

    // MARK: - Main View

    private lazy var mainScrollView = UIScrollView {
        VStack(
            alignment: .fill,
            margins: .init(top: 16, left: 16, bottom: 16, right: 16),
            spacing: 16
        ) {
            HStack(distribution: .fillEqually, spacing: 8) {
                makeStatCard(valueLabel: childrenValueLabel, key: "🌳 Children")
                makeStatCard(valueLabel: navStackValueLabel, key: "📚 Nav Stack")
                makeStatCard(valueLabel: eventsValueLabel, key: "📋 Events")
            }
            HStack(distribution: .fillEqually, spacing: 12) {
                launchChildButton
                launchDeepFlowButton
            }
            presentSheetButton
            Separator(color: .separator, height: 1)
            UILabel("Recent Events")
                .font(.systemFont(ofSize: 13, weight: .semibold))
                .textColor(.secondaryLabel)
            eventStack
        }
        .setConstraints {
            $0.snap(to: $1)
            $0.setWidth(to: $1.widthAnchor)
        }
    }
    .with { $0.alwaysBounceVertical = true }

    @UIViewBuilder override var mainView: UIView {
        mainScrollView
            .setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    // MARK: - Lifecycle

    override func setupView() {
        super.setupView()
        title = "Coordinator Demo"
        onViewWillAppear { [weak self] _ in
            self?.viewModel.requestStatsRefresh()
        }
    }

    // MARK: - Helpers

    private func makeStatValueLabel(id: String) -> UILabel {
        UILabel("0")
            .font(.systemFont(ofSize: 28, weight: .bold))
            .textAlignment(.center)
            .with { $0.accessibilityIdentifier = id }
    }

    private func makeStatCard(valueLabel: UILabel, key: String) -> UIView {
        VStack(alignment: .center, margins: .init(all: 12), spacing: 4) {
            valueLabel
            UILabel(key)
                .font(.systemFont(ofSize: 11, weight: .medium))
                .textColor(.secondaryLabel)
                .textAlignment(.center)
        }
        .backgroundColor(.secondarySystemBackground)
        .setAsRoundedView(radius: 10)
    }
}

// MARK: - CoordinatorDemoViewProtocol

extension CoordinatorDemoViewController: CoordinatorDemoViewProtocol {

    func updateStats(children: Int, navStack: Int, eventCount: Int) {
        childrenValueLabel.text("\(children)")
        navStackValueLabel.text("\(navStack)")
        eventsValueLabel.text("\(eventCount)")
    }

    func prependEvent(_ event: CoordinatorEvent) {
        let timeLabel = UILabel(event.time.toString(with: "HH:mm:ss"))
            .font(.monospacedSystemFont(ofSize: 11, weight: .regular))
            .textColor(.tertiaryLabel)

        let messageLabel = UILabel("\(event.icon) \(event.message)")
            .font(.systemFont(ofSize: 13))
            .textColor(.label)
            .numberOfLines(0)

        let row = VStack(
            alignment: .fill,
            margins: .init(horizontal: 12, vertical: 8),
            spacing: 2
        ) {
            messageLabel
            timeLabel
        }
        .backgroundColor(.secondarySystemBackground)
        .setAsRoundedView(radius: 8)

        eventStack.insertArrangedSubview(row, at: 0)
        mainScrollView.setContentOffset(.zero, animated: false)
    }
}
