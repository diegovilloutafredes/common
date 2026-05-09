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
        description: "Stacks children vertically. Each child fills the available width; height comes from the child's constraints or intrinsic size."
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
        description: "Stacks children horizontally. Width comes from each child's constraints or intrinsic size; height is determined by the tallest child."
    ) {
        HStack(distribution: .equalSpacing, spacing: 8) {
            colorBox(.systemPurple, label: "A")
            colorBox(.systemRed, label: "B")
            colorBox(.systemYellow, label: "C")
        }
    }

    // MARK: - Alignment Demo
    private lazy var alignmentDemo = demoSection(
        title: "Alignment",
        description: "Controls positioning on the cross axis (horizontal in a VStack, vertical in an HStack). Children keep their own sizes — only their cross-axis position shifts."
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
        description: "Controls how space is divided along the primary axis. Views need an intrinsic or explicit size for .fill and .equalSpacing to behave correctly — .fillEqually ignores size entirely."
    ) {
        VStack(spacing: 10) {
            distributionRow(.fill, title: ".fill",
                            subtitle: "first child expands to fill; others keep their size") {
                distBox(.systemPurple, label: "expands ›")
                distBox(.systemPink,   label: "60 pt", width: 60)
                distBox(.systemCyan,   label: "60 pt", width: 60)
            }
            distributionRow(.fillEqually, title: ".fillEqually",
                            subtitle: "all children share available width equally") {
                distBox(.systemPurple, label: "1/3")
                distBox(.systemPink,   label: "1/3")
                distBox(.systemCyan,   label: "1/3")
            }
            distributionRow(.equalSpacing, title: ".equalSpacing",
                            subtitle: "children keep own sizes; gaps between them equalize") {
                distBox(.systemPurple, label: "50 pt", width: 50)
                distBox(.systemPink,   label: "80 pt", width: 80)
                distBox(.systemCyan,   label: "40 pt", width: 40)
            }
        }
    }

    // MARK: - Margins Demo
    private lazy var marginsDemo = demoSection(
        title: "Margins",
        description: "UIEdgeInsets insets content from the container edges. The gray box is fixed-size — the teal region shows the remaining space after insets are applied."
    ) {
        HStack(distribution: .fillEqually, spacing: 10) {
            marginsCard(title: ".zero",             margins: .zero)
            marginsCard(title: ".init(all: 12)",    margins: .init(all: 12))
            marginsCard(title: ".init(h:12, v:6)",  margins: .init(horizontal: 12, vertical: 6))
        }
    }

    // MARK: - setRatio Demo
    private lazy var ratioDemo = demoSection(
        title: ".setRatio()",
        description: "Locks the width:height ratio. Pass width ÷ height as a CGFloat. Default is 1.0 (square). Combine with a single size constraint — width or height — to fully determine the frame."
    ) {
        HStack(alignment: .center, distribution: .fillEqually, spacing: 16) {
            VStack(alignment: .center, spacing: 4) {
                UIView().backgroundColor(.systemIndigo).round(radius: 8)
                    .setRatio()
                    .setConstraints { $0.set(width: 50) }
                UILabel().text("1:1")
                    .font(.systemFont(ofSize: 11)).textColor(.secondaryLabel).textAlignment(.center)
            }
            VStack(alignment: .center, spacing: 4) {
                UIView().backgroundColor(.systemMint).round(radius: 8)
                    .setRatio(16/9)
                    .setConstraints { $0.set(width: 80) }
                UILabel().text("16:9")
                    .font(.systemFont(ofSize: 11)).textColor(.secondaryLabel).textAlignment(.center)
            }
            VStack(alignment: .center, spacing: 4) {
                UIView().backgroundColor(.systemPink).round(radius: 8)
                    .setRatio(9/16)
                    .setConstraints { $0.set(width: 30) }
                UILabel().text("9:16")
                    .font(.systemFont(ofSize: 11)).textColor(.secondaryLabel).textAlignment(.center)
            }
        }
    }

    // MARK: - Nested Stacks Demo
    private lazy var nestedDemo = demoSection(
        title: "Nested Stacks",
        description: "VStack containing HStacks — a common card/form layout. Nesting is unlimited; each stack manages only its direct children."
    ) {
        VStack(margins: .init(all: 12), spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                UIView().backgroundColor(.systemBlue).round(radius: 20)
                    .setConstraints { $0.set(width: 40); $0.set(height: 40) }
                VStack(spacing: 2) {
                    UILabel().text("John Doe")
                        .font(.boldSystemFont(ofSize: 14)).textColor(.label)
                    UILabel().text("john@example.com")
                        .font(.systemFont(ofSize: 12)).textColor(.secondaryLabel)
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
        description: "Direct layout helpers used inside setConstraints { }. $0 is the view being laid out; $1 is its superview — available only in the two-argument overload."
    ) {
        VStack(spacing: 10) {
            constraintRow(
                label: ".snap(to: $1, insets: .init(all: 8))  —  pins all four edges with an 8 pt inset",
                containerHeight: 60,
                subviews: [
                    UIView()
                        .backgroundColor(.systemBlue.withAlphaComponent(0.25))
                        .round(radius: 4)
                        .setConstraints { $0.snap(to: $1, insets: .init(all: 8)) }
                ]
            )
            constraintRow(
                label: ".set(width: 120)  —  fixed 120 pt, centered in parent",
                subviews: [
                    UIView()
                        .backgroundColor(.systemOrange).round(radius: 4)
                        .setConstraints {
                            $0.set(width: 120)
                            $0.set(height: 28)
                            $0.alignCenterX(with: $1)
                            $0.alignCenterY(with: $1)
                        }
                ]
            )
            constraintRow(
                label: ".setWidth(to: $1.widthAnchor, multiplier: 0.6)  —  always 60% of parent",
                subviews: [
                    UIView()
                        .backgroundColor(.systemTeal).round(radius: 4)
                        .setConstraints {
                            $0.setWidth(to: $1.widthAnchor, multiplier: 0.6)
                            $0.set(height: 28)
                            $0.alignCenterX(with: $1)
                            $0.alignCenterY(with: $1)
                        }
                ]
            )
            constraintRow(
                label: ".snapCenter(to: $1)  —  centers in parent without affecting size",
                subviews: [
                    UIView()
                        .backgroundColor(.systemPurple).round(radius: 4)
                        .setConstraints {
                            $0.set(width: 100)
                            $0.set(height: 28)
                            $0.snapCenter(to: $1)
                        }
                ]
            )
        }
    }

    // MARK: - Optional Views Demo
    private lazy var optionalViewsDemo: UIView = {
        let present: UILabel? = UILabel()
            .text("① UILabel? (non-nil) — rendered")
            .font(.boldSystemFont(ofSize: 12))
            .textColor(.white)
            .backgroundColor(.systemGreen)
            .round(radius: 8)
            .textAlignment(.center)
            .setConstraints { $0.set(height: 36) }
        let absent: UIView? = nil
        return demoSection(
            title: "Optional Views",
            description: "UIView? expressions drop into stacks directly — no if let needed. Non-nil values appear normally; nil is removed from layout entirely with no reserved space."
        ) {
            VStack(spacing: 8) {
                present
                absent    // nil — dropped, no gap
                colorBar(.systemOrange, label: "② directly below ①: nil left no space")
                UILabel()
                    .text("absent was UIView? = nil — removed entirely. No gap exists between ① and ②.")
                    .font(.systemFont(ofSize: 11)).textColor(.secondaryLabel)
                    .numberOfLines(0).textAlignment(.center)
            }
        }
    }()

    // MARK: - Control Flow Demo
    private lazy var controlFlowDemo: UIView = {
        let showBonus = true
        let items: [(UIColor, String)] = [
            (.systemBlue,   "item 1"),
            (.systemGreen,  "item 2"),
            (.systemOrange, "item 3")
        ]
        return demoSection(
            title: "Control Flow",
            description: "for, if/else, and #available work natively inside any stack via result-builder support — no boilerplate needed."
        ) {
            VStack(spacing: 6) {
                cfSectionLabel("for", note: "each iteration adds one child view")
                for (color, label) in items { colorBar(color, label: label) }

                Separator(color: .separator, height: 0.5)

                cfSectionLabel("if / else", note: "only the matching branch is built into the tree")
                if showBonus {
                    colorBar(.systemPurple, label: "condition true → this branch is in the layout")
                } else {
                    colorBar(.systemGray,   label: "condition false → else branch replaces it")
                }

                Separator(color: .separator, height: 0.5)

                cfSectionLabel("#available", note: "view is included only when the OS version qualifies")
                if #available(iOS 16, *) {
                    UILabel()
                        .text("iOS 16+ — your device qualifies, so this view exists")
                        .font(.systemFont(ofSize: 12))
                        .textColor(.systemMint)
                        .textAlignment(.center)
                }
                UILabel()
                    .text("On older OS versions the view above is absent — no else, no empty slot.")
                    .font(.systemFont(ofSize: 11)).textColor(.tertiaryLabel)
                    .numberOfLines(0).textAlignment(.center)
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
                optionalViewsDemo
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

// MARK: - Section Container
extension DeclarativeUIViewController {
    private func demoSection(
        title: String,
        description: String,
        @UIViewBuilder content: () -> UIView
    ) -> UIView {
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
}

// MARK: - Primitive Helpers
extension DeclarativeUIViewController {
    private func colorBar(_ color: UIColor, label: String) -> UIView {
        UIView().backgroundColor(color).round(radius: 8)
            .setConstraints { $0.set(height: 36) }
            .with { bar in
                let lbl = UILabel()
                    .text(label).font(.boldSystemFont(ofSize: 12)).textColor(.white)
                    .setConstraints { $0.alignCenter(with: $1) }
                bar.addSubview(lbl)
            }
    }

    private func colorBox(_ color: UIColor, label: String) -> UIView {
        UIView().backgroundColor(color).round(radius: 8)
            .setConstraints { $0.set(width: 50); $0.set(height: 50) }
            .with { box in
                let lbl = UILabel()
                    .text(label).font(.boldSystemFont(ofSize: 14)).textColor(.white)
                    .setConstraints { $0.alignCenter(with: $1) }
                box.addSubview(lbl)
            }
    }
}

// MARK: - Alignment Helpers
extension DeclarativeUIViewController {
    private func alignmentExample(_ alignment: UIStackView.Alignment, label: String) -> UIView {
        VStack(spacing: 4) {
            UILabel()
                .text(label).font(.systemFont(ofSize: 10)).textColor(.tertiaryLabel)
                .textAlignment(.center)
            VStack(alignment: alignment, margins: .init(all: 6), spacing: 4) {
                UIView().backgroundColor(.systemBlue).round(radius: 4)
                    .setConstraints { $0.set(height: 12); $0.set(width: 60) }
                UIView().backgroundColor(.systemGreen).round(radius: 4)
                    .setConstraints { $0.set(height: 12); $0.set(width: 40) }
                UIView().backgroundColor(.systemOrange).round(radius: 4)
                    .setConstraints { $0.set(height: 12); $0.set(width: 50) }
            }
            .backgroundColor(.systemGray6).round(radius: 6)
        }
    }
}

// MARK: - Distribution Helpers
extension DeclarativeUIViewController {

    /// A colored box for the distribution demo.
    /// Pass `width: nil` to let the stack control its width (used for .fill and .fillEqually).
    private func distBox(_ color: UIColor, label: String, width: CGFloat? = nil) -> UIView {
        UIView()
            .backgroundColor(color).round(radius: 4)
            .setConstraints { view in
                view.set(height: 28)
                if let w = width { view.set(width: w) }
            }
            .with { box in
                let lbl = UILabel()
                    .text(label).textAlignment(.center)
                    .font(.boldSystemFont(ofSize: 10)).textColor(.white)
                    .setConstraints { $0.alignCenter(with: $1) }
                box.addSubview(lbl)
            }
    }

    private func distributionRow(
        _ distribution: UIStackView.Distribution,
        title: String,
        subtitle: String,
        @UIViewsBuilder boxes: () -> [UIView]
    ) -> UIView {
        VStack(spacing: 4) {
            HStack(alignment: .center, spacing: 4) {
                UILabel().text(title)
                    .font(.boldSystemFont(ofSize: 12)).textColor(.label)
                UILabel().text("— \(subtitle)")
                    .font(.systemFont(ofSize: 10)).textColor(.secondaryLabel).numberOfLines(0)
            }
            HStack(distribution: distribution, margins: .init(all: 6), spacing: 6, views: boxes)
                .backgroundColor(.systemGray6).round(radius: 6)
        }
    }
}

// MARK: - Margins Helpers
extension DeclarativeUIViewController {
    private func marginsCard(title: String, margins: UIEdgeInsets) -> UIView {
        VStack(spacing: 6) {
            UILabel()
                .text(title)
                .font(.monospacedSystemFont(ofSize: 10, weight: .regular))
                .textColor(.secondaryLabel).textAlignment(.center).numberOfLines(0)
            // Fixed-size gray box — the teal area shows what remains after insets
            UIView()
                .backgroundColor(.systemGray5).round(radius: 6)
                .setConstraints { $0.set(height: 60) }
                .with { container in
                    let inner = VStack(margins: margins) {
                        UIView().backgroundColor(.systemTeal).round(radius: 4)
                    }
                    container.addSubview(inner)
                    inner.setConstraints { $0.snap(to: $1) }
                }
        }
    }
}

// MARK: - Constraints Helpers
extension DeclarativeUIViewController {

    /// A labeled gray container that demonstrates a constraint API.
    /// Each view in `subviews` must configure its own constraints via setConstraints { } —
    /// $1 will be this gray container at the time the handler fires.
    private func constraintRow(
        label: String,
        containerHeight: CGFloat = 52,
        subviews: [UIView]
    ) -> UIView {
        VStack(spacing: 4) {
            UILabel()
                .text(label)
                .font(.systemFont(ofSize: 11))
                .textColor(.secondaryLabel)
                .numberOfLines(0)
            UIView()
                .backgroundColor(.systemGray5).round(radius: 8)
                .setConstraints { $0.set(height: containerHeight) }
                .with { container in container.subviews(subviews) }
        }
    }
}

// MARK: - Control Flow Helpers
extension DeclarativeUIViewController {
    private func cfSectionLabel(_ keyword: String, note: String) -> UIView {
        HStack(alignment: .center, spacing: 6) {
            UILabel()
                .text(keyword)
                .font(.monospacedSystemFont(ofSize: 11, weight: .bold))
                .textColor(.systemBlue)
                .setConstraints { $0.set(width: 72) }
            UILabel()
                .text(note)
                .font(.systemFont(ofSize: 11)).textColor(.secondaryLabel).numberOfLines(0)
        }
    }
}
