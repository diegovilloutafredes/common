//
//  AlertView.swift
//

import UIKit

// MARK: - AlertView

/// A view responsible for displaying the content of an alert, driven by an `AlertViewModel`.
public final class AlertView: BaseViewModelableView<AlertViewModel> {
    private lazy var iconImageView = UIImageView()
        .contentMode(.scaleAspectFit)
        .image(viewModel.icon)
        .tintColor(viewModel.iconTintColor)
        .setRatio()
        .setConstraints { $0.setWidth(to: $1.widthAnchor, multiplier: 0.3) }

    private lazy var actionButton = ActionButton(shouldApplyDefaultRatio: false)
        .onTap { [weak self] in self?.viewModel.onAction?() }
        .setAsRoundedView(radius: .DefaultValues.Button.cornerRadius)
        .title(viewModel.actionButtonTitle)
        .setConstraints { $0.set(height: 40) }

    private var shouldAddIconImageView: Bool { viewModel.icon.isNotNil }
    private var shouldAddCancelButton: Bool { viewModel.onCancel.isNotNil }

    /// The attributed message with the default font, the message color and the alignment filled into the ranges that
    /// set none. Setting them on the label instead would restyle the whole string, wiping the message's own styling.
    private var message: NSAttributedString {
        let message = NSMutableAttributedString(attributedString: viewModel.attributedMessage)
        let defaults: [(NSAttributedString.Key, Any)] = [
            (.font, UIFont.systemFont(ofSize: 16)),
            (.foregroundColor, viewModel.messageColor),
            (.paragraphStyle, NSMutableParagraphStyle().with { $0.alignment = viewModel.messageAlignment })
        ]
        defaults.forEach { key, value in
            message.enumerateAttribute(key, in: NSRange(location: .zero, length: message.length)) { existing, range, _ in
                if existing == nil { message.addAttribute(key, value: value, range: range) }
            }
        }
        return message
    }

    @UIViewBuilder
    public override var mainView: UIView {
        VStack(
            margins: .init(top: 16, left: 24, bottom: 16, right: 24),
            spacing: .DefaultValues.StackView.spacing
        ) {
            if shouldAddIconImageView { VStack(alignment: .center) { iconImageView } }

            UILabel()
                .font(.boldSystemFont(ofSize: 21))
                .numberOfLines(.zero)
                .text(viewModel.title)
                .textAlignment(.center)
                .textColor(viewModel.titleColor)

            UILabel()
                .adjustsFontSizeToFitWidth(true)
                .numberOfLines(.zero)
                .attributedText(message)

            shouldAddCancelButton ?
            HStack(
                alignment: .fill,
                distribution: .fillEqually,
                spacing: .DefaultValues.StackView.spacing
            ) {
                ActionButton(shouldApplyDefaultRatio: false, theme: DefaultButtonTheme.border)
                    .onTap { [weak self] in self?.viewModel.onCancel?() }
                    .setAsRoundedView(radius: .DefaultValues.Button.cornerRadius)
                    .title(viewModel.cancelButtonTitle)

                actionButton
            } :
            VStack(
                alignment: .trailing,
                spacing: .zero
            ) { actionButton.setRatio(120/40) }
        }.setConstraints { $0.snap(to: $1) }
    }

    public override func setupView() {
        backgroundColor(viewModel.backgroundColor)
    }
}
