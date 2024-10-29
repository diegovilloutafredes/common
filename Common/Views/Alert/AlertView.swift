//
//  AlertView.swift
//

import UIKit

// MARK: - AlertView
public final class AlertView: BaseViewModelableView<AlertViewModel> {
    private lazy var iconImageView = UIImageView()
        .contentMode(.scaleAspectFit)
        .image(viewModel?.icon)
        .tintColor(viewModel?.iconTintColor)
        .setRatio()
        .setConstraints { $0.setWidth(to: $1.widthAnchor, multiplier: 0.3) }

    private lazy var actionButton = ActionButton(shouldApplyDefaultRatio: false)
        .onTap { self.viewModel?.onActionButtonPressedHandler?() }
        .setAsRoundedView(radius: .DefaultValues.Button.cornerRadius)
        .title(viewModel?.actionButtonTitle)
        .setConstraints { $0.set(height: 40) }

    private var shouldAddIconImageView: Bool { viewModel?.icon.isNotNil ?? false }
    private var shouldAddCancelButton: Bool { viewModel?.onCancelButtonPressedHandler.isNotNil ?? false }

    @UIViewBuilder public override var mainView: UIView {
        VStack(
            margins: .init(top: 16, left: 24, bottom: 16, right: 24),
            spacing: .DefaultValues.StackView.spacing
        ) {
            if shouldAddIconImageView { VStack(alignment: .center) { iconImageView } }

            UILabel()
                .font(.boldSystemFont(ofSize: 21))
                .numberOfLines(.zero)
                .text(viewModel?.title)
                .textAlignment(.center)
                .textColor(viewModel?.titleColor)

            UILabel()
                .adjustsFontSizeToFitWidth(true)
                .attributedText(viewModel?.attributedMessage)
                .font(.systemFont(ofSize: 16))
                .numberOfLines(.zero)
                .textAlignment(viewModel?.messageAlignment)
                .textColor(viewModel?.messageColor)

            shouldAddCancelButton ?
            HStack(
                alignment: .fill,
                distribution: .fillEqually,
                spacing: .DefaultValues.StackView.spacing
            ) {
                ActionButton(shouldApplyDefaultRatio: false, theme: DefaultButtonTheme.border)
                    .onTap { self.viewModel?.onCancelButtonPressedHandler?() }
                    .setAsRoundedView(radius: .DefaultValues.Button.cornerRadius)
                    .title(viewModel?.cancelButtonTitle)

                actionButton
            } :
            VStack(
                alignment: .trailing,
                spacing: .zero
            ) { actionButton.setRatio(120/40) }
        }.setConstraints { $0.snap(to: $1) }
    }

    public override func setupView() {
        backgroundColor(viewModel?.backgroundColor)
    }
}
