//
//  ComponentsViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ComponentsViewController
final class ComponentsViewController: BaseViewModelableViewController<ComponentsViewModelProtocol> {

    // MARK: - GradientView demo
    private lazy var verticalGradient = GradientView()
        .with {
            $0.startColor = .systemBlue
            $0.endColor = .systemTeal
            $0.endLocation = 1
        }
        .round(radius: 12)
        .setConstraints { $0.set(height: 72) }

    private lazy var diagonalGradient = GradientView()
        .with {
            $0.startColor = .systemPurple
            $0.endColor = .systemOrange
            $0.endLocation = 1
            $0.horizontalMode = true
            $0.diagonalMode = true
        }
        .round(radius: 12)
        .setConstraints { $0.set(height: 72) }

    // MARK: - ProgressAnimationView demo
    private lazy var progressView = ProgressAnimationView()
        .backgroundColor(.systemGray5)
        .round(radius: 8)
        .setConstraints { $0.set(height: 16) }

    private lazy var progressStatusLabel = UILabel()
        .text("Tap Animate to run a 1.5 s determinate sweep")
        .font(.systemFont(ofSize: 13))
        .textColor(.secondaryLabel)
        .numberOfLines(0)

    private lazy var progressButton = UIButton(
        configuration: .filled()
            .with {
                $0.title = "Animate"
                $0.baseBackgroundColor = .systemGreen
                $0.cornerStyle = .capsule
            }
    )
    .onTap { [weak self] in self?.runProgressAnimation() }
    .setConstraints { $0.set(height: 44) }

    // MARK: - Layout
    @UIViewBuilder
    override var mainView: UIView {
        UIScrollView {
            VStack(
                margins: .init(top: 24, left: 16, bottom: 32, right: 16),
                spacing: 16
            ) {
                demoSection(
                    title: "GradientView",
                    description: "CAGradientLayer-backed view — configure colors, locations, and horizontal/diagonal direction."
                ) {
                    VStack(spacing: 12) {
                        verticalGradient
                        diagonalGradient
                    }
                }
                demoSection(
                    title: "PillUILabel",
                    description: "Label with pill-shaped background — padding is baked into its intrinsic size."
                ) {
                    HStack(alignment: .center, spacing: 8) {
                        PillUILabel()
                            .text("NEW")
                            .font(.systemFont(ofSize: 12, weight: .bold))
                        PillUILabel()
                            .text("Featured")
                            .backgroundColor(.systemIndigo)
                        PillUILabel()
                            .text("Sale")
                            .backgroundColor(.systemPink)
                        UIView()
                    }
                }
                demoSection(
                    title: "ProgressAnimationView",
                    description: "Gradient-based determinate progress animation with a completion callback."
                ) {
                    VStack(spacing: 12) {
                        progressView
                        progressStatusLabel
                        progressButton
                    }
                }
            }.setConstraints {
                $0.snap(to: $1)
                $0.setWidth(to: $1.widthAnchor)
            }
        }.setConstraints { $0.snap(to: $1) }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemBackground)
    }
}

// MARK: - ComponentsViewProtocol
extension ComponentsViewController: ComponentsViewProtocol {}

// MARK: - Private
private extension ComponentsViewController {
    func runProgressAnimation() {
        progressStatusLabel.text("Animating…").textColor(.secondaryLabel)
        progressView.animate(
            progressColor: UIColor.systemGreen.cgColor,
            backgroundColor: UIColor.systemGray5.cgColor,
            duration: 1.5
        ) { [weak self] in
            self?.progressStatusLabel.text("Completed ✓").textColor(.systemGreen)
        }
    }

    func demoSection(title: String, description: String, @UIViewBuilder content: () -> UIView) -> UIView {
        VStack(
            margins: .init(top: 16, left: 16, bottom: 16, right: 16),
            spacing: 12
        ) {
            UILabel()
                .text(title)
                .font(.boldSystemFont(ofSize: 18))
                .textColor(.label)
            UILabel()
                .text(description)
                .font(.systemFont(ofSize: 13))
                .textColor(.secondaryLabel)
                .numberOfLines(0)
            content()
        }
        .backgroundColor(.secondarySystemBackground)
        .round(radius: 12)
    }
}
