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

    private lazy var lifecycleLogLabel = UILabel()
        .font(.systemFont(ofSize: 12, weight: .medium))
        .textColor(.label)
        .numberOfLines(0)
        .text("Navigate away and back to see all events fire.")

    private var tapCount = 0 {
        didSet { tapCountLabel.text("Taps: \(tapCount) (should be +1 per tap)") }
    }
    private lazy var tapCountLabel = UILabel()
        .font(.monospacedSystemFont(ofSize: 13, weight: .regular))
        .textColor(.label)
        .text("Taps: 0 (should be +1 per tap)")
    private lazy var tapTargetView = UIView()
        .backgroundColor(.systemOrange)
        .round(radius: 10)
        .setConstraints { $0.set(height: 60) }

    @UIViewBuilder
    override var mainView: UIView {
        UIScrollView {
            VStack(
                margins: .init(top: 24, left: 16, bottom: 32, right: 16),
                spacing: 16
            ) {
                demoSection(
                    title: "Swizzle lifecycle hooks",
                    description: "onViewWillAppear / onViewIsAppearing / onViewDidAppear fire on arrival. Navigate away to trigger the disappear hooks (check Xcode console)."
                ) {
                    lifecycleLogLabel
                }
                demoSection(
                    title: "Gesture accumulation fix",
                    description: "onTap is re-registered 3× on the same view (simulates cell reuse). Each tap must count +1, not +3. Tap the orange view to verify."
                ) {
                    VStack(spacing: 8) {
                        tapCountLabel
                        tapTargetView
                        UIButton(
                            configuration: .filled().with {
                                $0.title = "Re-register ×3 and reset"
                                $0.baseBackgroundColor = .systemOrange
                                $0.cornerStyle = .capsule
                            }
                        )
                        .onTap { [weak self] in
                            guard let self else { return }
                            self.tapCount = 0
                            for _ in 0..<3 {
                                self.tapTargetView.onTap { [weak self] _, _ in
                                    self?.tapCount += 1
                                }
                            }
                        }
                        .setConstraints { $0.set(height: 44) }
                    }
                }
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
                        UIView()
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
        setupLifecycleHooks()
        setupGestureAccumulationTest()
    }

    private func setupGestureAccumulationTest() {
        for _ in 0..<3 {
            tapTargetView.onTap { [weak self] _, _ in
                self?.tapCount += 1
            }
        }
    }

    private func setupLifecycleHooks() {
        onViewWillAppear { [weak self] _ in
            self?.logLifecycleEvent("viewWillAppear")
        }
        onViewIsAppearing { [weak self] _ in
            self?.logLifecycleEvent("viewIsAppearing")
        }
        onViewDidAppear { [weak self] _ in
            self?.logLifecycleEvent("viewDidAppear")
        }
        onViewWillDisappear { [weak self] _ in
            self?.logLifecycleEvent("viewWillDisappear")
        }
        onViewDidDisappear { [weak self] _ in
            self?.logLifecycleEvent("viewDidDisappear")
        }
    }

    private var lifecycleEvents: [String] = [] {
        didSet { lifecycleLogLabel.text(lifecycleEvents.joined(separator: "\n")) }
    }

    private func logLifecycleEvent(_ name: String) {
        let entry = "[\(timestamp())] \(name) fired"
        print("[SwizzleTest] \(entry)")
        lifecycleEvents.append(entry)
    }

    private func timestamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f.string(from: Date())
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
        VStack(spacing: 4) {
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
