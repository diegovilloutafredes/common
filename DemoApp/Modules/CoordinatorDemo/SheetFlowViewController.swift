//
//  SheetFlowViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - SheetFlowViewController

/// A static modal screen presented as a detented sheet by the coordinator.
/// Simple screen — closure-wired, no ViewModel/Wireframe ceremony.
final class SheetFlowViewController: BaseViewController {

    private let onDismissRequested: Action
    private let onSwapRequested: Action?

    init(onDismissRequested: @escaping Action, onSwapRequested: Action? = nil) {
        self.onDismissRequested = onDismissRequested
        self.onSwapRequested = onSwapRequested
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder: NSCoder) { fatalError() }

    private lazy var dismissButton = UIButton(
        configuration: .filled().with {
            $0.title = "Dismiss Sheet"
            $0.cornerStyle = .capsule
            $0.image = UIImage(systemName: "chevron.down.circle.fill")
            $0.imagePadding = 6
        }
    )
    .onTap { [weak self] in self?.onDismissRequested() }
    .setConstraints { $0.set(height: 48) }

    // Only the first sheet offers the swap — the replacement sheet has no
    // onSwapRequested, and ArrayBuilder drops the nil button from layout.
    private lazy var swapButton: UIButton? = onSwapRequested.map { onSwap in
        UIButton(
            configuration: .bordered().with {
                $0.title = "Swap Sheet — present(.dismissingCurrent)"
                $0.cornerStyle = .capsule
                $0.image = UIImage(systemName: "rectangle.2.swap")
                $0.imagePadding = 6
            }
        )
        .onTap(onSwap)
        .setConstraints { $0.set(height: 48) }
    }

    @UIViewBuilder override var mainView: UIView {
        VStack(
            alignment: .fill,
            margins: .init(top: 24, left: 24, bottom: 24, right: 24),
            spacing: 16
        ) {
            UILabel("Sheet Presentation")
                .font(.systemFont(ofSize: 22, weight: .bold))
            UILabel("Presented by the coordinator with present(.overCurrent) — the medium detent, grabber, and corner radius are configured through the UISheetPresentationController chainables. Dismissing routes back through the coordinator's dismiss().")
                .font(.systemFont(ofSize: 14))
                .textColor(.secondaryLabel)
                .numberOfLines()
            dismissButton
            swapButton
            UIView()
        }.setConstraints { $0.snapLeadTopTrail(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        view.backgroundColor(.systemBackground)
    }
}
