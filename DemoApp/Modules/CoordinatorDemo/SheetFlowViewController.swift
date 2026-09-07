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

    /// Both answered by the presenting coordinator.
    enum Requested { case dismiss, swap }

    private let canSwap: Bool
    private let onRequested: Handler<Requested>

    init(canSwap: Bool = false, onRequested: @escaping Handler<Requested>) {
        self.canSwap = canSwap
        self.onRequested = onRequested
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
    .onTap { [weak self] in self?.onRequested(.dismiss) }
    .setConstraints { $0.set(height: 48) }

    // Only the first sheet offers the swap — the replacement sheet cannot swap,
    // and ArrayBuilder drops the nil button from layout.
    private lazy var swapButton: UIButton? = {
        guard canSwap else { return nil }
        return UIButton(
            configuration: .bordered().with {
                $0.title = "Swap Sheet — present(.dismissingCurrent)"
                $0.cornerStyle = .capsule
                $0.image = UIImage(systemName: "rectangle.2.swap")
                $0.imagePadding = 6
            }
        )
        .onTap { [weak self] in self?.onRequested(.swap) }
        .setConstraints { $0.set(height: 48) }
    }()

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
