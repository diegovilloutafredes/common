//
//  CustomAlertViewController.swift
//

import UIKit

// MARK: - CustomAlertViewController
public final class CustomAlertViewController: BaseViewController {
    private let backgroundColor: UIColor
    private let contentView: UIView
    private var onDismissRequestedHandler: CompletionHandler

    public init(backgroundColor: UIColor = .black.withAlphaComponent(0.5), contentView: UIView, onDismissRequested handler: CompletionHandler = nil) {
        self.backgroundColor = backgroundColor
        self.contentView = contentView
        self.onDismissRequestedHandler = handler
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    @UIViewBuilder public override var mainView: UIView {
        UIButton()
            .backgroundColor(backgroundColor)
            .onTap { _ in self.onDismissRequestedHandler?() }
            .setConstraints { $0.snap(to: $1) }
        contentView
            .cornerRadius(.DefaultValues.AlertView.cornerRadius)
            .setConstraints {
                $0.alignCenterY(with: $1)
                $0.snapLeadTrail(to: $1, insets: .init(top: .zero, left: 32, bottom: .zero, right: 32))
            }
    }

    public override func setupView() {
        backgroundColor(.clear)
    }
}
