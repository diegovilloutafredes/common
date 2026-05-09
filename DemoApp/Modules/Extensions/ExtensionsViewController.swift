//
//  ExtensionsViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ExtensionsViewController
final class ExtensionsViewController: BaseViewModelableViewController<ExtensionsViewModelProtocol> {

    private static let demoNotification = Notification.Name("com.common.demo.notification")

    // MARK: - UISwitch demo
    private lazy var switchStateLabel: UILabel = UILabel()
        .font(.monospacedSystemFont(ofSize: 14, weight: .regular))
        .textColor(.label)
        .text("OFF")

    private lazy var toggle: UISwitch = UISwitch()
        .onValueChanged { [weak self] sw in
            self?.switchStateLabel.text(sw.isOn ? "ON" : "OFF")
        }

    // MARK: - UISlider demo
    private lazy var sliderValueLabel: UILabel = UILabel()
        .font(.monospacedSystemFont(ofSize: 14, weight: .regular))
        .textColor(.label)
        .text("Value: 50")

    private lazy var slider: UISlider = UISlider()
        .minimumValue(0)
        .maximumValue(100)
        .value(50, animated: false)
        .minimumTrackTintColor(.systemBlue)
        .onValueChanged { [weak self] val in
            self?.sliderValueLabel.text("Value: \(Int(val))")
        }

    // MARK: - Notification demo
    private lazy var notificationLabel: UILabel = UILabel()
        .font(.monospacedSystemFont(ofSize: 13, weight: .regular))
        .textColor(.label)
        .text("Waiting for notification…")

    // MARK: - Random color demo
    private lazy var randomColorView: UIView = UIView()
        .randomBackgroundColor()
        .round(radius: 12)
        .setConstraints { $0.set(height: 60) }
        .onTap { [weak self] _, _ in self?.randomColorView.randomBackgroundColor() }

    // MARK: - UIColor.inverted demo
    private lazy var invertedOriginalBox: UIView = UIView()
        .backgroundColor(.systemBlue)
        .round(radius: 8)
        .setConstraints { $0.set(height: 56) }

    private lazy var invertedInvertedBox: UIView = UIView()
        .backgroundColor(.systemBlue.inverted)
        .round(radius: 8)
        .setConstraints { $0.set(height: 56) }

    @UIViewBuilder
    override var mainView: UIView {
        UIScrollView {
            VStack(
                margins: .init(top: 24, left: 16, bottom: 32, right: 16),
                spacing: 16
            ) {
                demoSection(
                    title: "UISwitch.onValueChanged",
                    description: "Chainable handler replaces UIControl target/action boilerplate. Toggle the switch."
                ) {
                    HStack(alignment: .center, spacing: 12) {
                        toggle
                        switchStateLabel
                    }
                }
                demoSection(
                    title: "UISlider.onValueChanged",
                    description: ".minimumValue() / .maximumValue() / .minimumTrackTintColor() — all chainable. Drag the slider."
                ) {
                    VStack(spacing: 8) {
                        sliderValueLabel
                        slider
                    }
                }
                demoSection(
                    title: "Int.asCurrency + .asDecimalNumber",
                    description: "Locale-aware formatting using es_CL. Both use a shared cached NumberFormatter."
                ) {
                    VStack(spacing: 4) {
                        formattingRow(label: "1234567.asCurrency", value: 1234567.asCurrency)
                        formattingRow(label: "1234567.asDecimalNumber", value: 1234567.asDecimalNumber)
                        formattingRow(label: "99.asCurrency", value: 99.asCurrency)
                    }
                }
                demoSection(
                    title: "String.isValidEmail",
                    description: "NSDataDetector-based email validation — no regex, anchored full-string match."
                ) {
                    VStack(spacing: 6) {
                        emailRow("user@example.com")
                        emailRow("good+tag@domain.io")
                        emailRow("not-an-email")
                        emailRow("missing@tld")
                        emailRow("mailto:user@example.com")
                    }
                }
                demoSection(
                    title: "Bundle.appVersion / .displayName / .buildNumber",
                    description: "Typed accessors for common Info.plist values — no magic strings."
                ) {
                    VStack(spacing: 4) {
                        formattingRow(label: "displayName", value: Bundle.main.displayName)
                        formattingRow(label: "versionNumber", value: Bundle.main.versionNumber)
                        formattingRow(label: "buildNumber", value: Bundle.main.buildNumber)
                        formattingRow(label: "appVersion", value: Bundle.main.appVersion)
                    }
                }
                demoSection(
                    title: "Date.toString(with:) + .epochTime",
                    description: "Cached DateFormatter per format string, es_CL locale. epochTime is a static Int64."
                ) {
                    VStack(spacing: 4) {
                        formattingRow(label: "yyyy-MM-dd", value: Date().toString(with: "yyyy-MM-dd"))
                        formattingRow(label: "dd/MM/yyyy HH:mm", value: Date().toString(with: "dd/MM/yyyy HH:mm"))
                        formattingRow(label: "epochTime", value: "\(Date.epochTime)")
                    }
                }
                demoSection(
                    title: "UIColor.inverted",
                    description: "Returns a new color with each RGB channel inverted (1 − component), alpha preserved. Tap either swatch to randomize."
                ) {
                    HStack(distribution: .fillEqually, spacing: 12) {
                        swatchBoxed(invertedOriginalBox, label: "original")
                        swatchBoxed(invertedInvertedBox, label: ".inverted")
                    }
                    .onTap { [weak self] _, _ in self?.randomizeInvertedColor() }
                }
                demoSection(
                    title: "NSObject.observe(_:action:) + .post(_:)",
                    description: "Typed notification observation without Selector boilerplate. Tap the button to post."
                ) {
                    VStack(spacing: 8) {
                        notificationLabel
                        UIButton(
                            configuration: .filled().with {
                                $0.title = "Post notification"
                                $0.baseBackgroundColor = .systemTeal
                                $0.cornerStyle = .capsule
                            }
                        )
                        .onTap { [weak self] in
                            self?.post(ExtensionsViewController.demoNotification)
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
                    title: "setAsRoundedView — pill shape + clipsToBounds caveat",
                    description: "setAsRoundedView() hooks layoutSubviews and reads bounds.height after Auto Layout resolves — so radius: nil gives a perfect pill on any height, including after rotation. shadow() without clipsToBounds is correct; enabling clipsToBounds clips the shadow."
                ) {
                    VStack(spacing: 12) {
                        HStack(alignment: .center, spacing: 16) {
                            UIView()
                            VStack(spacing: 4) {
                                UILabel()
                                    .text("radius: nil (pill)")
                                    .font(.monospacedSystemFont(ofSize: 10, weight: .regular))
                                    .textColor(.secondaryLabel)
                                    .textAlignment(.center)
                                UILabel()
                                    .text("Badge")
                                    .font(.boldSystemFont(ofSize: 12))
                                    .textColor(.white)
                                    .textAlignment(.center)
                                    .backgroundColor(.systemPurple)
                                    .setAsRoundedView()
                                    .setConstraints { $0.set(height: 28); $0.set(minWidth: 64) }
                            }
                            VStack(spacing: 4) {
                                UILabel()
                                    .text("radius: 6")
                                    .font(.monospacedSystemFont(ofSize: 10, weight: .regular))
                                    .textColor(.secondaryLabel)
                                    .textAlignment(.center)
                                UILabel()
                                    .text("Badge")
                                    .font(.boldSystemFont(ofSize: 12))
                                    .textColor(.white)
                                    .textAlignment(.center)
                                    .backgroundColor(.systemBlue)
                                    .setAsRoundedView(radius: 6)
                                    .setConstraints { $0.set(height: 28); $0.set(minWidth: 64) }
                            }
                            UIView()
                        }
                        HStack(alignment: .center, spacing: 8) {
                            UILabel()
                                .text("round + shadow (correct):")
                                .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
                                .textColor(.secondaryLabel)
                            UIView()
                            UIView()
                                .backgroundColor(.systemGreen)
                                .round(radius: 12)
                                .shadow(color: .systemGreen, offset: .init(width: 0, height: 3), opacity: 0.5, radius: 8)
                                .setConstraints { $0.set(width: 80); $0.set(height: 36) }
                        }
                        HStack(alignment: .center, spacing: 8) {
                            UILabel()
                                .text("clipsToBounds=true clips shadow:")
                                .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
                                .textColor(.secondaryLabel)
                                .numberOfLines(0)
                            UIView()
                            UIView()
                                .backgroundColor(.systemOrange)
                                .round(radius: 12)
                                .shadow(color: .systemOrange, offset: .init(width: 0, height: 3), opacity: 0.5, radius: 8)
                                .clipsToBounds(true)
                                .setConstraints { $0.set(width: 80); $0.set(height: 36) }
                        }
                        VStack(spacing: 6) {
                            UILabel()
                                .text("subview clipping — white box overflows top-left corner")
                                .font(.monospacedSystemFont(ofSize: 10, weight: .regular))
                                .textColor(.secondaryLabel)
                            HStack(alignment: .top, spacing: 32) {
                                UIView()
                                clipCompareView(label: "round()\nno clipping", clipped: false)
                                clipCompareView(label: "setAsRoundedView()\nclips subviews", clipped: true)
                                UIView()
                            }
                        }
                    }
                }
                demoSection(
                    title: "maskedCorners — selective corner rounding",
                    description: "CACornerMask lets you round any subset of corners. round() and setAsRoundedView() both accept a corners: parameter."
                ) {
                    HStack(distribution: .fillEqually, spacing: 8) {
                        cornerSwatch(label: "all", corners: .all)
                        cornerSwatch(label: "top", corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
                        cornerSwatch(label: "bottom", corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
                        cornerSwatch(label: "diagonal", corners: [.layerMinXMinYCorner, .layerMaxXMaxYCorner])
                    }
                }
                demoSection(
                    title: "borderColor + borderWidth",
                    description: "Layer-level border composable with corner radius. Border is always drawn inside the view's bounds."
                ) {
                    HStack(alignment: .center, spacing: 12) {
                        UIView()
                        UIView()
                            .backgroundColor(.systemBackground)
                            .round(radius: 12)
                            .borderColor(.systemBlue)
                            .borderWidth(2)
                            .setConstraints { $0.set(width: 60); $0.set(height: 60) }
                        UIView()
                            .backgroundColor(.systemBackground)
                            .setAsRoundedView()
                            .borderColor(.systemGreen)
                            .borderWidth(3)
                            .setConstraints { $0.set(width: 60); $0.set(height: 60) }
                        UIView()
                            .backgroundColor(.systemBackground)
                            .round(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20)
                            .borderColor(.systemOrange)
                            .borderWidth(2)
                            .setConstraints { $0.set(width: 60); $0.set(height: 60) }
                        UIView()
                    }
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
                demoSection(
                    title: "CGFloat.DefaultValues + TimeInterval.DefaultValues",
                    description: "Typed semantic constants for radii, margins, and animation durations — no magic numbers."
                ) {
                    VStack(spacing: 4) {
                        formattingRow(label: "AlertView.cornerRadius", value: "\(CGFloat.DefaultValues.AlertView.cornerRadius)")
                        formattingRow(label: "Button.cornerRadius", value: "\(CGFloat.DefaultValues.Button.cornerRadius)")
                        formattingRow(label: "StackView.topMargin", value: "\(CGFloat.DefaultValues.StackView.topMargin)")
                        formattingRow(label: "TimeInterval.animationDuration", value: "\(TimeInterval.DefaultValues.animationDuration)s")
                    }
                }
                demoSection(
                    title: "Array+FloatingPoint — .sum / .average / .standardDeviation",
                    description: "Statistical helpers on any [FloatingPoint] array."
                ) {
                    VStack(spacing: 4) {
                        formattingRow(label: "values", value: "[1, 2, 3, 4, 5]")
                        formattingRow(label: ".sum", value: "\([1.0, 2, 3, 4, 5].sum)")
                        formattingRow(label: ".average", value: "\([1.0, 2, 3, 4, 5].average)")
                        formattingRow(label: ".standardDeviation", value: String(format: "%.4f", [1.0, 2, 3, 4, 5].standardDeviation))
                    }
                }
                demoSection(
                    title: "String.hyphened + .isRUT + .formatAsRUT()",
                    description: "Chilean RUT utilities — validation via Módulo 11 and dot/hyphen formatting."
                ) {
                    VStack(spacing: 4) {
                        formattingRow(label: "\"123456789\".hyphened", value: "123456789".hyphened)
                        formattingRow(label: "\"12345678-9\".isRUT", value: "\("12345678-9".isRUT)")
                        formattingRow(label: "\"not-a-rut\".isRUT", value: "\("not-a-rut".isRUT)")
                        formattingRow(label: "\"12345678-9\".formatAsRUT()", value: "12345678-9".formatAsRUT())
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
        notificationLabel.observe(ExtensionsViewController.demoNotification) { [weak self] in
            self?.notificationLabel.text("Received at \(Date().toString(with: "HH:mm:ss"))")
        }
    }

    private func randomizeInvertedColor() {
        let color = UIColor.randomColor
        invertedOriginalBox.backgroundColor(color)
        invertedInvertedBox.backgroundColor(color.inverted)
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

    private func swatchBoxed(_ box: UIView, label: String) -> UIView {
        VStack(spacing: 4) {
            box
            UILabel()
                .text(label)
                .font(.boldSystemFont(ofSize: 12))
                .textColor(.secondaryLabel)
                .textAlignment(.center)
        }
    }

    private func formattingRow(label: String, value: String) -> UIView {
        HStack(alignment: .center, spacing: 8) {
            UILabel()
                .text(label)
                .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
                .textColor(.secondaryLabel)
            UIView()
            UILabel()
                .text(value)
                .font(.monospacedSystemFont(ofSize: 12, weight: .bold))
                .textColor(.label)
                .textAlignment(.right)
        }
    }

    private func emailRow(_ email: String) -> UIView {
        HStack(alignment: .center, spacing: 8) {
            UIImageView(image: .init(systemName: email.isValidEmail ? "checkmark.circle.fill" : "xmark.circle.fill"))
                .tintColor(email.isValidEmail ? .systemGreen : .systemRed)
                .contentMode(.scaleAspectFit)
                .setConstraints { $0.set(width: 16); $0.set(height: 16) }
            UILabel()
                .text(email)
                .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
                .textColor(.label)
        }
    }

    private func cornerSwatch(label: String, corners: CACornerMask) -> UIView {
        VStack(spacing: 4) {
            UIView()
                .backgroundColor(.systemPurple)
                .round(corners: corners, radius: 18)
                .setConstraints { $0.set(height: 56) }
            UILabel()
                .text(label)
                .font(.monospacedSystemFont(ofSize: 10, weight: .regular))
                .textColor(.secondaryLabel)
                .textAlignment(.center)
                .numberOfLines(0)
        }
    }

    private func clipCompareView(label: String, clipped: Bool) -> UIView {
        VStack(spacing: 4) {
            UIView()
                .backgroundColor(.systemBlue)
                .with {
                    if clipped {
                        $0.setAsRoundedView(radius: 16)
                    } else {
                        $0.round(radius: 16)
                    }
                    let overflow = UIView(frame: .init(x: -6, y: -6, width: 28, height: 28))
                    overflow.backgroundColor = .white
                    overflow.layer.cornerRadius = 4
                    $0.addSubview(overflow)
                }
                .setConstraints { $0.set(width: 56); $0.set(height: 56) }
            UILabel()
                .text(label)
                .font(.monospacedSystemFont(ofSize: 9, weight: .regular))
                .textColor(.secondaryLabel)
                .textAlignment(.center)
                .numberOfLines(0)
        }
    }
}
