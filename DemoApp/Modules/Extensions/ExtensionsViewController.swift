//
//  ExtensionsViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ExtensionsViewController
final class ExtensionsViewController: BaseViewModelableViewController<ExtensionsViewModelProtocol> {
    private lazy var randomColorView: UIView = UIView()
        .randomBackgroundColor()
        .round(radius: 12)
        .setConstraints { $0.set(height: 60) }
        .with { view in
            let tap = UITapGestureRecognizer()
            tap.addTarget(self, action: #selector(randomColorViewTapped))
            view.addGestureRecognizer(tap)
            view.isUserInteractionEnabled = true
        }

    @UIViewBuilder
    override var mainView: UIView {
        UIScrollView()
            .setConstraints { $0.snap(to: $1) }
            .with { scroll in
                let contentStack = VStack(
                    margins: .init(top: 24, left: 16, bottom: 32, right: 16),
                    spacing: 20
                ) {
                    demoSection(label: "UIView extensions (.round, .shadow, .backgroundColor)") {
                        UIView()
                            .backgroundColor(.systemBlue)
                            .round(radius: 16)
                            .shadow(
                                color: .systemBlue,
                                offset: .init(width: 0, height: 4),
                                opacity: 0.4,
                                radius: 8
                            )
                            .setConstraints { $0.set(height: 60) }
                    }

                    demoSection(label: "UILabel extensions (.text, .font, .textColor)") {
                        UILabel()
                            .text("Hello extensions!")
                            .font(.boldSystemFont(ofSize: 20))
                            .textColor(.systemPurple)
                            .textAlignment(.center)
                    }

                    demoSection(label: "UIButton extensions (.onTap, configuration)") {
                        UIButton(
                            configuration: .filled()
                                .with {
                                    $0.title = "Tap me"
                                    $0.baseBackgroundColor = .systemGreen
                                    $0.cornerStyle = .capsule
                                }
                        )
                        .onTap { Snackbar.show(.init(message: "Button tapped!")) }
                        .setConstraints { $0.set(height: 44) }
                    }

                    demoSection(label: "randomBackgroundColor() — tap to change") {
                        randomColorView
                    }

                    demoSection(label: "UIColor with alpha variations") {
                        HStack(spacing: 8) {
                            colorSwatch(color: .systemBlue, label: "systemBlue")
                            colorSwatch(color: .systemBlue.withAlphaComponent(0.6), label: "60% alpha")
                            colorSwatch(color: .systemBlue.withAlphaComponent(0.3), label: "30% alpha")
                        }
                    }
                }
                contentStack.translatesAutoresizingMaskIntoConstraints = false
                scroll.addSubview(contentStack)
                NSLayoutConstraint.activate([
                    contentStack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
                    contentStack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
                    contentStack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
                    contentStack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
                    contentStack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
                ])
            }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemBackground)
    }

    private func demoSection(label: String, @UIViewsBuilder content: () -> [UIView]) -> UIView {
        VStack(
            margins: .init(top: 12, left: 12, bottom: 12, right: 12),
            spacing: 8
        ) {
            UILabel()
                .text(label)
                .font(.systemFont(ofSize: 12))
                .textColor(.secondaryLabel)
                .numberOfLines(0)
            content()[0]
        }
        .backgroundColor(.secondarySystemBackground)
        .round(radius: 12)
    }

    private func colorSwatch(color: UIColor, label: String) -> UIView {
        VStack(alignment: .center, spacing: 4) {
            UIView()
                .backgroundColor(color)
                .round(radius: 8)
                .setConstraints { $0.set(height: 40) }
            UILabel()
                .text(label)
                .font(.systemFont(ofSize: 11))
                .textColor(.secondaryLabel)
                .textAlignment(.center)
        }
    }

    @objc private func randomColorViewTapped() {
        randomColorView.randomBackgroundColor()
    }
}
