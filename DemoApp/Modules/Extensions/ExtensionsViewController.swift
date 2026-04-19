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
        .onTap { [weak self] _, _ in self?.randomColorView.randomBackgroundColor() }

    @UIViewBuilder
    override var mainView: UIView {
        UIScrollView()
            .setConstraints { $0.snap(to: $1) }
            .with { scroll in
                let contentStack = VStack(
                    margins: .init(top: 24, left: 16, bottom: 32, right: 16),
                    spacing: 16
                ) {
                    demoSection(
                        title: ".round() + .shadow()",
                        description: "Combine corner radius with drop shadow for card-like appearance."
                    ) {
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

                    demoSection(
                        title: ".text() + .font() + .textColor()",
                        description: "Fluent chaining for UILabel configuration."
                    ) {
                        UILabel()
                            .text("Hello extensions!")
                            .font(.boldSystemFont(ofSize: 20))
                            .textColor(.systemPurple)
                            .textAlignment(.center)
                    }

                    demoSection(
                        title: ".onTap { } + UIButton.Configuration",
                        description: "Tap handler and modern button configuration API."
                    ) {
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

                    demoSection(
                        title: ".setRatio()",
                        description: "Constrains aspect ratio. Square (1:1) and wide (2:1)."
                    ) {
                        HStack(alignment: .center, spacing: 12) {
                            UIView().backgroundColor(.systemIndigo).round(radius: 8)
                                .setRatio()
                                .setConstraints { $0.set(width: 60) }
                            UIView().backgroundColor(.systemMint).round(radius: 8)
                                .setRatio(2)
                                .setConstraints { $0.set(width: 120) }
                        }
                    }

                    demoSection(
                        title: ".randomBackgroundColor()",
                        description: "Tap the view below to randomize its color."
                    ) {
                        randomColorView
                    }

                    demoSection(
                        title: ".withAlphaComponent()",
                        description: "Same color at different opacity levels."
                    ) {
                        HStack(distribution: .fillEqually, spacing: 8) {
                            colorSwatch(color: .systemBlue, label: "100%")
                            colorSwatch(color: .systemBlue.withAlphaComponent(0.6), label: "60%")
                            colorSwatch(color: .systemBlue.withAlphaComponent(0.3), label: "30%")
                            colorSwatch(color: .systemBlue.withAlphaComponent(0.1), label: "10%")
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

    private func demoSection(title: String, description: String, @UIViewBuilder content: () -> UIView) -> UIView {
        VStack(
            margins: .init(top: 12, left: 12, bottom: 12, right: 12),
            spacing: 8
        ) {
            UILabel().text(title).font(.boldSystemFont(ofSize: 14)).textColor(.label)
            UILabel().text(description).font(.systemFont(ofSize: 12)).textColor(.secondaryLabel).numberOfLines(0)
            content()
        }
        .backgroundColor(.secondarySystemBackground)
        .round(radius: 12)
    }

    private func colorSwatch(color: UIColor, label: String) -> UIView {
        VStack(alignment: .center, spacing: 4) {
            UIView()
                .backgroundColor(color)
                .round(radius: 8)
                .setConstraints { $0.set(height: 56) }
            UILabel()
                .text(label)
                .font(.boldSystemFont(ofSize: 12))
                .textColor(.secondaryLabel)
                .textAlignment(.center)
        }
    }
}
