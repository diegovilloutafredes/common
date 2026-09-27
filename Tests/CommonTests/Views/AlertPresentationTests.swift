//
//  AlertPresentationTests.swift
//

import XCTest
@testable import Common

/// System alerts must be readable in either appearance, and custom alerts must not keep themselves
/// or their view model's handlers alive. Taps and presentation live in HostedTests: control actions
/// and the key window need the app host.
@MainActor
final class AlertPresentationTests: XCTestCase {

    private final class Presenter: AlertPresentable {}

    // MARK: - System alert colors follow the appearance

    func test_defaultAlertStyle_isWhiteInDarkAppearance_andBlackInLight() throws {
        let alert = UIAlertController(title: "Title", message: "Message", preferredStyle: .alert)
        Presenter().applyDefaultAlertStyle(to: alert, alertTitle: "Title", alertMessage: "Message")

        let title = try XCTUnwrap(alert.value(forKey: "attributedTitle") as? NSAttributedString)
        let message = try XCTUnwrap(alert.value(forKey: "attributedMessage") as? NSAttributedString)
        let parts: [(String, UIColor?)] = [
            ("tint", alert.view.tintColor),
            ("title", title.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor),
            ("message", message.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor)
        ]
        for (part, color) in parts {
            let color = try XCTUnwrap(color, part)
            XCTAssertEqual(rgba(color, in: .dark), [1, 1, 1, 1], "\(part) must be readable in dark appearance")
            XCTAssertEqual(rgba(color, in: .light), [0, 0, 0, 1], "\(part) must stay black in light appearance")
        }
    }

    // MARK: - Custom alerts do not retain themselves

    /// Deallocates only when everything that captured it has been released.
    private final class Sentinel {}

    func test_customAlertController_isReleased_afterItsViewLoaded() {
        weak var weakController: CustomAlertViewController?
        autoreleasepool {
            let controller = CustomAlertViewController(contentView: UIView(), onDismissRequested: {})
            controller.loadViewIfNeeded()  // builds mainView, which installs the background tap handler
            weakController = controller
        }
        XCTAssertNil(weakController, "the background tap handler must not retain the controller")
    }

    func test_alertView_isReleased_withWhatItsViewModelsHandlersCapture() {
        weak var weakView: AlertView?
        weak var weakSentinel: Sentinel?
        autoreleasepool {
            let sentinel = Sentinel()
            let view = AlertView(viewModel: payload(onAction: { _ = sentinel }, onCancel: { _ = sentinel }))
            weakView = view
            weakSentinel = sentinel
        }
        XCTAssertNil(weakView, "the action and cancel tap handlers must not retain the view")
        XCTAssertNil(weakSentinel, "the view model's handlers must be released with the view")
    }

    // MARK: - A custom alert keeps its message's styling

    private func messageLabel(in view: UIView, text: String) throws -> UILabel {
        func labels(in view: UIView) -> [UILabel] { view.subviews.flatMap { ($0 as? UILabel).map { [$0] } ?? labels(in: $0) } }
        return try XCTUnwrap(labels(in: view).first { $0.attributedText?.string == text }, "the message label")
    }

    /// The defect: the label's font, color and alignment were set after the attributed message, wiping its styling.
    func test_alertView_keepsTheMessagesOwnStyling_andFillsTheRest() throws {
        let bold = UIFont.boldSystemFont(ofSize: 20)
        let message = NSMutableAttributedString(string: "Bold", attributes: [.font: bold, .foregroundColor: UIColor.red])
        message.append(NSAttributedString(string: " plain"))
        let view = AlertView(viewModel: AlertViewModelPayload(title: "Title", attributedMessage: message, onActionButtonPressedHandler: nil))

        let rendered = try XCTUnwrap(try messageLabel(in: view, text: "Bold plain").attributedText)
        XCTAssertEqual(rendered.attribute(.font, at: 0, effectiveRange: nil) as? UIFont, bold)
        XCTAssertEqual(rendered.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor, .red)
        XCTAssertEqual(rendered.attribute(.font, at: 5, effectiveRange: nil) as? UIFont, .systemFont(ofSize: 16))
        XCTAssertEqual(rendered.attribute(.foregroundColor, at: 5, effectiveRange: nil) as? UIColor, .black)
    }

    func test_alertView_plainMessage_usesTheDefaults() throws {
        let view = AlertView(viewModel: AlertViewModelPayload(title: "Title", attributedMessage: .init(string: "Plain"), onActionButtonPressedHandler: nil))

        let rendered = try XCTUnwrap(try messageLabel(in: view, text: "Plain").attributedText)
        XCTAssertEqual(rendered.attribute(.font, at: 0, effectiveRange: nil) as? UIFont, .systemFont(ofSize: 16))
        XCTAssertEqual(rendered.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor, .black)
        XCTAssertEqual((rendered.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle)?.alignment, .center)
    }

    private func payload(onAction: CompletionHandler, onCancel: CompletionHandler) -> AlertViewModelPayload {
        AlertViewModelPayload(title: "Title", attributedMessage: .init(string: "Message"),
                              onActionButtonPressedHandler: onAction, onCancelButtonPressedHandler: onCancel)
    }

    private func rgba(_ color: UIColor, in style: UIUserInterfaceStyle) -> [CGFloat] {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.resolvedColor(with: UITraitCollection(userInterfaceStyle: style)).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue, alpha].map { ($0 * 100).rounded() / 100 }
    }
}
