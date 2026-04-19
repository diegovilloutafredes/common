//
//  DeclarativeUIViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - DeclarativeUIViewController
final class DeclarativeUIViewController: BaseViewModelableViewController<DeclarativeUIViewModelProtocol> {

    // MARK: - VStack Demo
    private lazy var vStackDemo = demoSection(
        title: "VStack",
        description: "Arranges views vertically with configurable spacing."
    ) {
        VStack(spacing: 8) {
            colorBar(.systemBlue, label: "Item 1")
            colorBar(.systemGreen, label: "Item 2")
            colorBar(.systemOrange, label: "Item 3")
        }
    }

    // MARK: - HStack Demo
    private lazy var hStackDemo = demoSection(
        title: "HStack",
        description: "Arranges views horizontally with configurable spacing."
    ) {
        HStack(spacing: 8) {
            colorBox(.systemPurple, label: "A")
            colorBox(.systemRed, label: "B")
            colorBox(.systemYellow, label: "C")
        }
    }

    // MARK: - Alignment Demo
    private lazy var alignmentDemo = demoSection(
        title: "Alignment",
        description: "Controls how views align within the stack: .leading, .center, .trailing."
    ) {
        HStack(distribution: .fillEqually, spacing: 8) {
            alignmentExample(.leading, label: ".leading")
            alignmentExample(.center, label: ".center")
            alignmentExample(.trailing, label: ".trailing")
        }
    }

    // MARK: - Distribution Demo
    private lazy var distributionDemo = demoSection(
        title: "Distribution",
        description: "Controls how space is divided: .fill, .fillEqually, .equalSpacing."
    ) {
        VStack(spacing: 12) {
            distributionExample(.fill, label: ".fill")
            distributionExample(.fillEqually, label: ".fillEqually")
            distributionExample(.equalSpacing, label: ".equalSpacing")
        }
    }

    // MARK: - Margins Demo
    private lazy var marginsDemo = demoSection(
        title: "Margins",
        description: "UIEdgeInsets padding inside the stack container."
    ) {
        HStack(distribution: .fillEqually, spacing: 8) {
            VStack(alignment: .center, spacing: 4) {
                UILabel().text("No margins").font(.systemFont(ofSize: 11)).textColor(.secondaryLabel)
                VStack {
                    colorBar(.systemTeal, label: "Content")
                }
                .backgroundColor(.systemGray5)
                .round(radius: 8)
            }
            VStack(alignment: .center, spacing: 4) {
                UILabel().text("16pt margins").font(.systemFont(ofSize: 11)).textColor(.secondaryLabel)
                VStack(margins: .init(top: 16, left: 16, bottom: 16, right: 16)) {
                    colorBar(.systemTeal, label: "Content")
                }
                .backgroundColor(.systemGray5)
                .round(radius: 8)
            }
        }
    }

    // MARK: - setRatio Demo
    private lazy var ratioDemo = demoSection(
        title: ".setRatio()",
        description: "Constrains a view's aspect ratio. Width/height ratio."
    ) {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .center, spacing: 4) {
                UIView().backgroundColor(.systemIndigo).round(radius: 8)
                    .setRatio()
                    .setConstraints { $0.set(width: 50) }
                UILabel().text("1:1").font(.systemFont(ofSize: 11)).textColor(.secondaryLabel).textAlignment(.center)
            }
            VStack(alignment: .center, spacing: 4) {
                UIView().backgroundColor(.systemMint).round(radius: 8)
                    .setRatio(16/9)
                    .setConstraints { $0.set(width: 80) }
                UILabel().text("16:9").font(.systemFont(ofSize: 11)).textColor(.secondaryLabel).textAlignment(.center)
            }
            VStack(alignment: .center, spacing: 4) {
                UIView().backgroundColor(.systemPink).round(radius: 8)
                    .setRatio(9/16)
                    .setConstraints { $0.set(width: 30) }
                UILabel().text("9:16").font(.systemFont(ofSize: 11)).textColor(.secondaryLabel).textAlignment(.center)
            }
        }
    }

    // MARK: - Nested Stacks Demo
    private lazy var nestedDemo = demoSection(
        title: "Nested Stacks",
        description: "VStack containing HStacks — a common form/card layout."
    ) {
        VStack(margins: .init(top: 12, left: 12, bottom: 12, right: 12), spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                UIView().backgroundColor(.systemBlue).round(radius: 20)
                    .setConstraints { $0.set(width: 40); $0.set(height: 40) }
                VStack(spacing: 2) {
                    UILabel().text("John Doe").font(.boldSystemFont(ofSize: 14)).textColor(.label)
                    UILabel().text("john@example.com").font(.systemFont(ofSize: 12)).textColor(.secondaryLabel)
                }
            }
            Separator(color: .separator, height: 0.5)
            HStack(distribution: .equalSpacing) {
                UILabel().text("Role").font(.systemFont(ofSize: 13)).textColor(.secondaryLabel)
                UILabel().text("Developer").font(.boldSystemFont(ofSize: 13)).textColor(.label)
            }
            HStack(distribution: .equalSpacing) {
                UILabel().text("Status").font(.systemFont(ofSize: 13)).textColor(.secondaryLabel)
                UILabel().text("Active").font(.boldSystemFont(ofSize: 13)).textColor(.systemGreen)
            }
        }
        .backgroundColor(.systemGray6)
        .round(radius: 12)
    }

    // MARK: - Constraints Demo
    private lazy var constraintsDemo = demoSection(
        title: "Constraints",
        description: ".snap(to:), .alignCenter(with:), .set(width:), .setWidth(to:, multiplier:)"
    ) {
        VStack(spacing: 8) {
            UIView().backgroundColor(.systemGray5).round(radius: 8).setConstraints { $0.set(height: 40) }
                .with { parent in
                    let label = UILabel().text(".snap(to:) — fills parent").font(.systemFont(ofSize: 11)).textColor(.secondaryLabel)
                        .textAlignment(.center).setConstraints { $0.alignCenter(with: $1) }
                    parent.subviews { label }
                }
            UIView().backgroundColor(.systemGray5).round(radius: 8).setConstraints { $0.set(height: 40) }
                .with { parent in
                    let box = UIView().backgroundColor(.systemOrange).round(radius: 6)
                        .setConstraints { $0.alignCenter(with: $1); $0.set(width: 100); $0.set(height: 24) }
                    let label = UILabel().text(".set(width: 100)").font(.systemFont(ofSize: 10)).textColor(.white)
                        .textAlignment(.center).setConstraints { $0.alignCenter(with: $1) }
                    parent.subviews { box }
                    box.subviews { label }
                }
            UIView().backgroundColor(.systemGray5).round(radius: 8).setConstraints { $0.set(height: 40) }
                .with { parent in
                    let box = UIView().backgroundColor(.systemTeal).round(radius: 6)
                        .setConstraints { $0.alignCenter(with: $1); $0.setWidth(to: $1.widthAnchor, multiplier: 0.5); $0.set(height: 24) }
                    let label = UILabel().text("50% width").font(.systemFont(ofSize: 10)).textColor(.white)
                        .textAlignment(.center).setConstraints { $0.alignCenter(with: $1) }
                    parent.subviews { box }
                    box.subviews { label }
                }
        }
    }

    // MARK: - Control Flow Demo
    private lazy var controlFlowDemo: UIView = {
        let showBonus = true
        let items: [(UIColor, String)] = [
            (.systemBlue, "for loop — item 1"),
            (.systemGreen, "for loop — item 2"),
            (.systemOrange, "for loop — item 3")
        ]
        return demoSection(
            title: "Control Flow",
            description: "for loops, if/else, and #available inside VStack/HStack — now natively supported."
        ) {
            VStack(spacing: 8) {
                for (color, label) in items {
                    colorBar(color, label: label)
                }
                if showBonus {
                    colorBar(.systemPurple, label: "if/else — condition is true")
                } else {
                    colorBar(.systemGray, label: "if/else — condition is false")
                }
                if #available(iOS 16, *) {
                    UILabel()
                        .text("#available(iOS 16+) — visible on this device")
                        .font(.systemFont(ofSize: 12))
                        .textColor(.systemMint)
                        .textAlignment(.center)
                }
            }
        }
    }()

    // MARK: - Main View
    @UIViewBuilder
    override var mainView: UIView {
        UIScrollView {
            VStack(
                margins: .init(top: 16, left: 16, bottom: 32, right: 16),
                spacing: 16
            ) {
                vStackDemo
                hStackDemo
                alignmentDemo
                distributionDemo
                marginsDemo
                ratioDemo
                nestedDemo
                constraintsDemo
                controlFlowDemo
            }.setConstraints {
                $0.snap(to: $1)
                $0.setWidth(to: $1.widthAnchor)
            }
        }.setConstraints { $0.snap(to: $1) }
    }

    override func setupView() {
        super.setupView()
        backgroundColor(.systemBackground)
        set(title: viewModel.title)
    }
}

// MARK: - Helpers
extension DeclarativeUIViewController {
    private func demoSection(title: String, description: String, @UIViewBuilder content: () -> UIView) -> UIView {
        VStack(
            margins: .init(top: 12, left: 12, bottom: 12, right: 12),
            spacing: 8
        ) {
            UILabel().text(title).font(.boldSystemFont(ofSize: 16)).textColor(.label)
            UILabel().text(description).font(.systemFont(ofSize: 12)).textColor(.secondaryLabel).numberOfLines(0)
            content()
        }
        .backgroundColor(.secondarySystemBackground)
        .round(radius: 12)
    }

    private func colorBar(_ color: UIColor, label: String) -> UIView {
        UIView().backgroundColor(color).round(radius: 8).setConstraints { $0.set(height: 36) }
            .with { bar in
                let lbl = UILabel().text(label).font(.boldSystemFont(ofSize: 12)).textColor(.white)
                    .setConstraints { $0.alignCenter(with: $1) }
                bar.subviews { lbl }
            }
    }

    private func colorBox(_ color: UIColor, label: String) -> UIView {
        UIView().backgroundColor(color).round(radius: 8)
            .setConstraints { $0.set(width: 50); $0.set(height: 50) }
            .with { box in
                let lbl = UILabel().text(label).font(.boldSystemFont(ofSize: 14)).textColor(.white)
                    .setConstraints { $0.alignCenter(with: $1) }
                box.subviews { lbl }
            }
    }

    private func alignmentExample(_ alignment: UIStackView.Alignment, label: String) -> UIView {
        VStack(spacing: 4) {
            UILabel().text(label).font(.systemFont(ofSize: 10)).textColor(.tertiaryLabel).textAlignment(.center)
            VStack(alignment: alignment, margins: .init(top: 6, left: 6, bottom: 6, right: 6), spacing: 4) {
                UIView().backgroundColor(.systemBlue).round(radius: 4).setConstraints { $0.set(height: 12); $0.set(width: 60) }
                UIView().backgroundColor(.systemGreen).round(radius: 4).setConstraints { $0.set(height: 12); $0.set(width: 40) }
                UIView().backgroundColor(.systemOrange).round(radius: 4).setConstraints { $0.set(height: 12); $0.set(width: 50) }
            }
            .backgroundColor(.systemGray6).round(radius: 6)
        }
    }

    private func distributionExample(_ distribution: UIStackView.Distribution, label: String) -> UIView {
        VStack(spacing: 4) {
            UILabel().text(label).font(.systemFont(ofSize: 11)).textColor(.tertiaryLabel)
            HStack(distribution: distribution, margins: .init(top: 4, left: 4, bottom: 4, right: 4), spacing: 4) {
                UIView().backgroundColor(.systemPurple).round(radius: 4).setConstraints { $0.set(height: 24) }
                UIView().backgroundColor(.systemPink).round(radius: 4).setConstraints { $0.set(height: 24) }
                UIView().backgroundColor(.systemCyan).round(radius: 4).setConstraints { $0.set(height: 24) }
            }
            .backgroundColor(.systemGray6).round(radius: 6)
        }
    }
}
