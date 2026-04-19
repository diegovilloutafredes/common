//
//  SnackbarView.swift
//

import UIKit

// MARK: - SnackbarViewModel
protocol SnackbarViewModel: ViewModel {
    var background: UIColor { get }
    var message: String { get }
    var messageFont: UIFont { get }
    var duration: TimeInterval { get }
    var actionTitle: String? { get }
    var actionFont: UIFont { get }
    var onAction: CompletionHandler { get }
    var onDismiss: CompletionHandler { get }
}

// MARK: - Default implementation
extension SnackbarViewModel {
    var background: UIColor { .systemGray.withAlphaComponent(0.95) }
}

// MARK: - SnackbarView

/// A view that displays the snackbar content.
final class SnackbarView: BaseViewModelableView<SnackbarViewModel> {
    @UIViewBuilder override var mainView: UIView {
        UIView {
            HStack( // DEBUG: outer wrapper should have red tint if 16pt gap exists
                alignment: .center,
                distribution: .equalSpacing,
                margins: .init(top: 16, left: 16, bottom: 16, right: 16),
                spacing: 8
            ) {
                UILabel(viewModel.message)
                    .adjustsFontSizeToFitWidth()
                    .textColor(.white)
                    .font(viewModel.messageFont)
                    .numberOfLines(3)

                if viewModel.actionTitle.isNotNil {
                    UIButton(type: .system)
                        .adjustsFontSizeToFitWidth()
                        .font(viewModel.actionFont)
                        .title(viewModel.actionTitle)
                        .titleColor(.white)
                        .onTap { [weak self] in guard let self else { return }
                            viewModel.onAction?()
                            dismiss()
                        }
                }
            }
            .backgroundColor(viewModel.background)
            .setAsRoundedView(radius: 4)
            .setConstraints { $0.snap(to: $1, insets: .init(top: .zero, left: 16, bottom: .zero, right: 16)) }
        }
    }

    // MARK: - Setup
    override func setupView() {
        super.setupView()
        guard let keyWindow else { return }
        setConstraints { $0.snapLeadBottomTrail(to: $1.safeAreaLayoutGuide) }
        keyWindow.addSubview(self)
    }

    private var timer: Timer?

    private var translationDistance: CGFloat { (keyWindow?.safeAreaInsets.bottom ?? .zero) + bounds.height + 32 }
}

extension SnackbarView {
    func present() {
        guard let keyWindow else { return }

        keyWindow.layoutIfNeeded()

        transform(.init(translationX: .zero, y: translationDistance))

        UIView.animate(
            withDuration: .DefaultValues.animationDuration,
            delay: .zero,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: .curveEaseInOut
        ) { [weak self] in guard let self else { return }; transform(.identity) }

        timer = .scheduledTimer(
            withTimeInterval: viewModel.duration,
            repeats: false
        ) { [weak self] _ in guard let self else { return }; dismiss() }
    }

    func dismiss() {
        timer?.invalidate()

        guard keyWindow.isNotNil else {
            removeFromSuperview()
            viewModel.onDismiss?()
            return
        }

        UIView.animate(
            withDuration: .DefaultValues.animationDuration,
            delay: .zero,
            options: .curveEaseInOut,
            animations: { [weak self] in guard let self else { return }; transform(.init(translationX: .zero, y: translationDistance)) }
        ) { [weak self] _ in guard let self else { return }
            removeFromSuperview()
            viewModel.onDismiss?()
        }
    }
}
