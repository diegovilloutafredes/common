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

    private lazy var mainScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        return sv
    }()

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

    // MARK: - Main View

    @UIViewBuilder override var mainView: UIView {
        mainScrollView
            .setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    // MARK: - Lifecycle

    override func setupView() {
        super.setupView()
        title = "Coordinator Demo"
        buildScrollContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.requestStatsRefresh()
    }

    // MARK: - Layout

    private func buildScrollContent() {
        let statsRow = HStack(distribution: .fillEqually, spacing: 8) {
            makeStatCard(valueLabel: childrenValueLabel, key: "🌳 Children")
            makeStatCard(valueLabel: navStackValueLabel, key: "📚 Nav Stack")
            makeStatCard(valueLabel: eventsValueLabel, key: "📋 Events")
        }

        let buttonsRow = HStack(distribution: .fillEqually, spacing: 12) {
            launchChildButton
            launchDeepFlowButton
        }

        let separator = UIView()
            .backgroundColor(.separator)
            .setConstraints { $0.set(height: 1) }

        let eventsHeader = UILabel("Recent Events")
            .font(.systemFont(ofSize: 13, weight: .semibold))
            .textColor(.secondaryLabel)

        let content = VStack(
            alignment: .fill,
            margins: .init(top: 16, left: 16, bottom: 16, right: 16),
            spacing: 16
        ) {
            statsRow
            buttonsRow
            separator
            eventsHeader
            eventStack
        }

        mainScrollView.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.widthAnchor),
        ])
    }

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
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"

        let timeLabel = UILabel(formatter.string(from: event.time))
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
