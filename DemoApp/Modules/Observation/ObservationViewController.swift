//
//  ObservationViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ObservationViewController
final class ObservationViewController: BaseCollectionViewableViewController<ObservationViewModelProtocol> {

    private lazy var countLabel = UILabel("Count: 0")
        .font(.monospacedSystemFont(ofSize: 34, weight: .bold))
        .textColor(.label)
        .textAlignment(.center)

    private lazy var modeLabel = UILabel()
        .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
        .textColor(.secondaryLabel)
        .textAlignment(.center)

    private lazy var incrementButton = UIButton(configuration: .filled().with {
        $0.title = "Increment"
        $0.baseBackgroundColor = .systemBlue
        $0.cornerStyle = .capsule
    })
    .onTap { [weak self] in self?.viewModel.increment() }
    .setConstraints { $0.set(height: 44) }

    private lazy var resetButton = UIButton(configuration: .filled().with {
        $0.title = "Reset"
        $0.baseBackgroundColor = .systemGray
        $0.cornerStyle = .capsule
    })
    .onTap { [weak self] in self?.viewModel.reset() }
    .setConstraints { $0.set(height: 44) }

    private lazy var badge = UnreadBadgeView(messages: viewModel.messages)

    private lazy var markAllReadButton = UIButton(configuration: .filled().with {
        $0.title = "Mark all read"
        $0.baseBackgroundColor = .systemGreen
        $0.cornerStyle = .capsule
    })
    .onTap { [weak self] in self?.viewModel.markAllRead() }
    .setConstraints { $0.set(height: 44) }

    private lazy var list = VList(dataSource: self, delegate: self)
        .register(MessageCell.self)
        .backgroundColor(.clear)
        .setConstraints { $0.set(height: MessageCell.height * 4) }

    @UIViewBuilder override var mainView: UIView {
        UIScrollView {
            VStack(margins: .init(top: 24, left: 16, bottom: 32, right: 16), spacing: 16) {
                demoSection(
                    title: "ViewModel.onUpdateProperties()",
                    description: "The buttons only mutate an @Observable model. The label, the Reset state and the mode line are written in one hook that UIKit (iOS 26) or Common (iOS 17–18) re-runs."
                ) {
                    VStack(spacing: 12) {
                        countLabel
                        HStack(distribution: .fillEqually, spacing: 8) {
                            incrementButton
                            resetButton
                        }
                        modeLabel
                    }
                }
                demoSection(
                    title: "BaseView.updateContent()",
                    description: "A BaseView renders itself from the message models. Tap a row or \"Mark all read\" and watch it update with no delegate."
                ) {
                    badge
                }
                demoSection(
                    title: "BaseViewModelableCell.updateContent()",
                    description: "Cells bind in updateContent() instead of viewModel didSet. Assignment and later model changes both re-run it — no reloadData."
                ) {
                    VStack(spacing: 12) {
                        markAllReadButton
                        list
                    }
                }
            }
            .setConstraints {
                $0.snap(to: $1)
                $0.setWidth(to: $1.widthAnchor)
            }
        }
        .setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemBackground)
    }

    private func demoSection(title: String, description: String, @UIViewBuilder content: () -> UIView) -> UIView {
        VStack(margins: .init(all: 12), spacing: 8) {
            UILabel().text(title).font(.boldSystemFont(ofSize: 14)).textColor(.label).numberOfLines(0)
            UILabel().text(description).font(.systemFont(ofSize: 12)).textColor(.secondaryLabel).numberOfLines(0)
            content()
        }
        .backgroundColor(.secondarySystemBackground)
        .round(radius: 12)
    }
}

// MARK: - ObservationViewProtocol
extension ObservationViewController: ObservationViewProtocol {
    func render(count: Int, unread: Int, mode: String) {
        countLabel.text("Count: \(count)")
        resetButton.isEnabled(count > .zero)
        modeLabel.text("ObservationMode.current = .\(mode) · \(unread) unread")
    }
}
