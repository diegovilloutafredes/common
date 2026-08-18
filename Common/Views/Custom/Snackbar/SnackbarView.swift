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
    private lazy var card = HStack(
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

    @UIViewBuilder override var mainView: UIView {
        UIView { card }
    }

    /// The full-width container exists only to position the card — touches on
    /// the transparent strips beside it must reach the UI beneath the snackbar.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        card.point(inside: convert(point, to: card), with: event)
    }

    // MARK: - Setup
    override func setupView() {
        super.setupView()
        guard let hostWindow else { return }
        setConstraints { $0.snapLeadBottomTrail(to: $1.safeAreaLayoutGuide) }
        hostWindow.addSubview(self)
    }

    private var timer: Timer?

    private var hostWindow: UIWindow? { Snackbar.hostWindow() }

    private var translationDistance: CGFloat { (hostWindow?.safeAreaInsets.bottom ?? .zero) + bounds.height + 32 }
}

extension SnackbarView {
    func present() {
        guard let hostWindow else {
            // No host window — the snackbar cannot show, but the caller still
            // gets its dismissal callback. dismiss()'s nil-window branch
            // delivers it without animating.
            return dismiss()
        }

        hostWindow.layoutIfNeeded()

        transform(.init(translationX: .zero, y: translationDistance))

        UIView.animate(
            withDuration: .DefaultValues.animationDuration,
            delay: .zero,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: .curveEaseInOut
        ) { [weak self] in guard let self else { return }; transform(.identity) }

        // Registered in .common (not the default mode a scheduled timer gets)
        // so auto-dismiss keeps counting while the user scrolls underneath.
        let timer = Timer(
            timeInterval: viewModel.duration,
            repeats: false
        ) { [weak self] _ in guard let self else { return }; dismiss() }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func dismiss() {
        timer?.invalidate()

        guard hostWindow.isNotNil else {
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
