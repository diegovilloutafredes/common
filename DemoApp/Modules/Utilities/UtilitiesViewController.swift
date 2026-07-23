//
//  UtilitiesViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - UtilitiesViewController
final class UtilitiesViewController: BaseViewModelableViewController<UtilitiesViewModelProtocol> {

    // MARK: - Debouncer demo
    private lazy var debouncedOutputLabel: UILabel = UILabel()
        .font(.monospacedSystemFont(ofSize: 13, weight: .regular))
        .textColor(.secondaryLabel)
        .text("Type to see debounced output…")
        .numberOfLines(0)

    private lazy var debounceSearchField: UITextField = UITextField()
        .placeholder("Type here…", color: .systemGray2, font: .systemFont(ofSize: 15))
        .borderColor(.systemGray4)
        .borderWidth(1)
        .setAsRoundedView(radius: 8)
        .setConstraints { $0.set(height: 44) }
        .with {
            $0.leftView = UIView(frame: .init(x: 0, y: 0, width: 10, height: 0))
            $0.leftViewMode = .always
        }
        .onEditingChanged { [weak self] field in
            let text = field.text ?? ""
            Debouncer.debounce(id: "search", seconds: 0.5) { [weak self] in
                let output = text.isEmpty ? "Type to see debounced output…" : "Debounced: \"\(text)\""
                self?.debouncedOutputLabel.text(output)
            }
        }

    // MARK: - UIDatePicker demo
    private lazy var selectedDateLabel: UILabel = UILabel()
        .font(.monospacedSystemFont(ofSize: 13, weight: .regular))
        .textColor(.secondaryLabel)
        .text("No date selected yet")

    private lazy var datePicker: UIDatePicker = UIDatePicker()
        .datePickerMode(.date)
        .preferredDatePickerStyle(.compact)
        .locale(Locale(identifier: "es_CL"))
        .maximumDate(.now)
        .onValueChanged { [weak self] date in
            self?.selectedDateLabel.text(date.toString(with: "dd MMM yyyy"))
        }

    // MARK: - CircularActivityIndicatorView demo
    private lazy var spinner: CircularActivityIndicatorView = CircularActivityIndicatorView(
        colors: [.systemBlue, .systemGreen, .systemPurple],
        lineWidth: 5
    )
    .setConstraints { $0.set(width: 56); $0.set(height: 56) }

    private lazy var spinnerToggleButton: UIButton = UIButton(
        configuration: .filled()
            .with {
                $0.title = "Start Spinner"
                $0.baseBackgroundColor = .systemBlue
                $0.cornerStyle = .capsule
            }
    )
    .onTap { [weak self] in self?.toggleSpinner() }
    .setConstraints { $0.set(height: 44) }

    // MARK: - Animation demos
    private lazy var alphaAnimView: UIView = UIView()
        .backgroundColor(.systemBlue)
        .round(radius: 12)
        .setConstraints { $0.set(height: 52) }

    private lazy var scaleAnimView: UIView = UIView()
        .backgroundColor(.systemGreen)
        .setAsRoundedView()
        .setConstraints { $0.set(width: 52); $0.set(height: 52) }

    private lazy var colorAnimView: UIView = UIView()
        .backgroundColor(.systemOrange)
        .round(radius: 12)
        .setConstraints { $0.set(height: 52) }

    private lazy var constraintBar: UIView = UIView()
        .backgroundColor(.systemIndigo)
        .round(radius: 8)
        .setConstraints { $0.set(height: 40) }

    // MARK: - Logger demo
    private lazy var loggerStatusLabel: UILabel = UILabel()
        .text("No logs emitted yet")
        .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
        .textColor(.secondaryLabel)
        .numberOfLines(0)

    private lazy var loggerButton: UIButton = UIButton(
        configuration: .filled()
            .with {
                $0.title = "Emit Log Frame"
                $0.baseBackgroundColor = .systemTeal
                $0.cornerStyle = .capsule
            }
    )
    .onTap { [weak self] in self?.emitLogFrame() }
    .setConstraints { $0.set(height: 44) }

    // MARK: - Shake & vibrate demo
    private lazy var shakeTarget: UILabel = UILabel()
        .text("Shake me")
        .font(.systemFont(ofSize: 14, weight: .medium))
        .textColor(.white)
        .textAlignment(.center)
        .backgroundColor(.systemRed)
        .round(radius: 8)
        .setConstraints { $0.set(height: 44) }

    private lazy var shakeButton: UIButton = UIButton(
        configuration: .filled()
            .with {
                $0.title = "Shake"
                $0.baseBackgroundColor = .systemRed
                $0.cornerStyle = .capsule
            }
    )
    .onTap { [weak self] in self?.shakeTarget.shake() }
    .setConstraints { $0.set(height: 44) }

    private lazy var vibrateButton: UIButton = UIButton(
        configuration: .filled()
            .with {
                $0.title = "Vibrate"
                $0.baseBackgroundColor = .systemGray
                $0.cornerStyle = .capsule
            }
    )
    .onTap { [weak self] in self?.vibrate() }
    .setConstraints { $0.set(height: 44) }

    private lazy var expandCollapseButton: UIButton = UIButton(
        configuration: .filled()
            .with {
                $0.title = "Expand"
                $0.baseBackgroundColor = .systemIndigo
                $0.cornerStyle = .capsule
            }
    )
    .onTap { [weak self] in self?.toggleBarWidth() }
    .setConstraints { $0.set(height: 44) }

    private var barWidthConstraint: NSLayoutConstraint?
    private var alphaIsHidden = false
    private var isBouncing = false
    private var colorIsAlternate = false
    private var isBarExpanded = false

    @UIViewBuilder
    override var mainView: UIView {
        UIScrollView {
            VStack(
                margins: .init(top: 24, left: 16, bottom: 32, right: 16),
                spacing: 16
            ) {
                demoSection(
                    title: "Debouncer.debounce(seconds:function:)",
                    description: "Collapses rapid calls into one — output updates 0.5 s after you stop typing."
                ) {
                    VStack(spacing: 8) {
                        debounceSearchField
                        debouncedOutputLabel
                    }
                }
                demoSection(
                    title: "UIDatePicker.onValueChanged(_:)",
                    description: "Chainable date picker with locale, style, and max-date configuration."
                ) {
                    VStack(spacing: 8) {
                        HStack(alignment: .center, spacing: 12) {
                            UILabel()
                                .text("Pick a date:")
                                .font(.systemFont(ofSize: 15))
                                .textColor(.label)
                            datePicker
                            UIView()
                        }
                        selectedDateLabel
                    }
                }
                demoSection(
                    title: "CircularActivityIndicatorView",
                    description: "Multi-color animated spinner. Tap the button to toggle."
                ) {
                    VStack(alignment: .center, spacing: 16) {
                        spinner
                        spinnerToggleButton
                    }
                }
                demoSection(
                    title: "UIView.animate — properties & constraint",
                    description: "alpha, backgroundColor, and transform are directly animatable. Constraint animation: update constraint.constant then call layoutIfNeeded() inside the animation block."
                ) {
                    VStack(spacing: 12) {
                        HStack(alignment: .center, spacing: 12) {
                            UILabel()
                                .text("alpha:")
                                .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
                                .textColor(.secondaryLabel)
                            alphaAnimView
                            UIButton(configuration: .filled().with {
                                $0.title = "Fade"
                                $0.baseBackgroundColor = .systemBlue
                                $0.cornerStyle = .capsule
                            })
                            .onTap { [weak self] in self?.toggleAlpha() }
                            .setConstraints { $0.set(height: 36); $0.set(width: 70) }
                        }
                        HStack(alignment: .center, spacing: 12) {
                            UILabel()
                                .text("transform:")
                                .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
                                .textColor(.secondaryLabel)
                            UIView()
                            scaleAnimView
                            UIView()
                            UIButton(configuration: .filled().with {
                                $0.title = "Bounce"
                                $0.baseBackgroundColor = .systemGreen
                                $0.cornerStyle = .capsule
                            })
                            .onTap { [weak self] in self?.triggerBounce() }
                            .setConstraints { $0.set(height: 36); $0.set(width: 90) }
                        }
                        HStack(alignment: .center, spacing: 12) {
                            UILabel()
                                .text("background:")
                                .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
                                .textColor(.secondaryLabel)
                            colorAnimView
                            UIButton(configuration: .filled().with {
                                $0.title = "Shift"
                                $0.baseBackgroundColor = .systemOrange
                                $0.cornerStyle = .capsule
                            })
                            .onTap { [weak self] in self?.toggleColor() }
                            .setConstraints { $0.set(height: 36); $0.set(width: 70) }
                        }
                        VStack(spacing: 8) {
                            UILabel()
                                .text("constraint (width):")
                                .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
                                .textColor(.secondaryLabel)
                            VStack(alignment: .leading) {
                                constraintBar
                            }
                            expandCollapseButton
                        }
                    }
                }
                demoSection(
                    title: "Logger",
                    description: "Compile-time DEBUG gated — silent in Release unless forceEnable() opts in. Frames print atomically to the Xcode console."
                ) {
                    VStack(spacing: 8) {
                        loggerStatusLabel
                        loggerButton
                    }
                }
                demoSection(
                    title: "Shake & Vibrate",
                    description: "UIView.shake() keyframe animation and UIViewController.vibrate() haptic (silent in the simulator)."
                ) {
                    VStack(spacing: 12) {
                        shakeTarget
                        HStack(distribution: .fillEqually, spacing: 8) {
                            shakeButton
                            vibrateButton
                        }
                    }
                }
            }
            .setConstraints {
                $0.snap(to: $1)
                $0.setWidth(to: $1.widthAnchor)
            }
        }
        .setConstraints { $0.snap(to: $1) }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemBackground)
        setupAsKeyboardDismissable()
        setupConstraintAnimation()
    }

    private var logCount = 0

    private func emitLogFrame() {
        logCount += 1
        Logger.forceEnable()
        Logger.log(["screen": "Utilities", "event": "logger-demo", "count": logCount])
        loggerStatusLabel.text("Emitted frame #\(logCount) — check the Xcode console")
            .textColor(.systemGreen)
    }

    private func setupConstraintAnimation() {
        // Deliberate raw-anchor use: the animation demo mutates this constraint's
        // `constant`, so it needs a stored reference — the DSL doesn't expose one.
        let c = constraintBar.widthAnchor.constraint(equalToConstant: 80)
        c.isActive = true
        barWidthConstraint = c
    }

    private var isSpinning = false

    private func toggleSpinner() {
        isSpinning.toggle()
        if isSpinning {
            spinner.startAnimating()
            spinnerToggleButton.configuration?.title = "Stop Spinner"
            spinnerToggleButton.configuration?.baseBackgroundColor = .systemRed
        } else {
            spinner.stopAnimating()
            spinnerToggleButton.configuration?.title = "Start Spinner"
            spinnerToggleButton.configuration?.baseBackgroundColor = .systemBlue
        }
    }

    private func toggleAlpha() {
        alphaIsHidden.toggle()
        UIView.animate(withDuration: 0.4) {
            self.alphaAnimView.alpha = self.alphaIsHidden ? 0.1 : 1.0
        }
    }

    private func triggerBounce() {
        guard !isBouncing else { return }
        isBouncing = true

        // keyTimes match: rest → impact1 → apex1 → impact2 → apex2 → impact3 → rest
        let times: [NSNumber] = [0, 0.28, 0.50, 0.67, 0.80, 0.91, 1.0]
        let easing = [CAMediaTimingFunction(name: .easeIn),  CAMediaTimingFunction(name: .easeOut),
                      CAMediaTimingFunction(name: .easeIn),  CAMediaTimingFunction(name: .easeOut),
                      CAMediaTimingFunction(name: .easeIn),  CAMediaTimingFunction(name: .easeOut)]

        func keyframeAnim(_ keyPath: String, _ values: [NSNumber]) -> CAKeyframeAnimation {
            let a = CAKeyframeAnimation(keyPath: keyPath)
            a.values = values; a.keyTimes = times; a.timingFunctions = easing
            return a
        }

        let group = CAAnimationGroup()
        group.animations = [
            keyframeAnim("transform.translation.y", [0, 70, 0, 36, 0, 14, 0]),
            keyframeAnim("transform.scale.x",       [1, 1.30, 1, 1.12, 1, 1.05, 1]),
            keyframeAnim("transform.scale.y",       [1, 0.65, 1, 0.80, 1, 0.92, 1]),
        ]
        group.duration = 1.1
        group.isRemovedOnCompletion = true

        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in self?.isBouncing = false }
        scaleAnimView.layer.add(group, forKey: "bounce")
        CATransaction.commit()
    }

    private func toggleColor() {
        colorIsAlternate.toggle()
        UIView.animate(withDuration: 0.5) {
            self.colorAnimView.backgroundColor = self.colorIsAlternate ? .systemPink : .systemOrange
        }
    }

    private func toggleBarWidth() {
        isBarExpanded.toggle()
        // outer margins (16×2) + card padding (12×2) = 56 total horizontal inset
        let expandedWidth = view.bounds.width - 56
        barWidthConstraint?.constant = isBarExpanded ? expandedWidth : 80
        expandCollapseButton.configuration?.title = isBarExpanded ? "Collapse" : "Expand"
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: []) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Factory

    private func demoSection(title: String, description: String, @UIViewBuilder content: () -> UIView) -> UIView {
        VStack(
            margins: .init(top: 12, left: 12, bottom: 12, right: 12),
            spacing: 8
        ) {
            UILabel().text(title).font(.boldSystemFont(ofSize: 14)).textColor(.label).numberOfLines(0)
            UILabel().text(description).font(.systemFont(ofSize: 12)).textColor(.secondaryLabel).numberOfLines(0)
            content()
        }
        .backgroundColor(.secondarySystemBackground)
        .round(radius: 12)
    }
}
