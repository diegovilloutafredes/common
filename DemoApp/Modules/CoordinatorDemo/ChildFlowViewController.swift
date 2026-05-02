//
//  ChildFlowViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ChildFlowViewController

final class ChildFlowViewController: UIViewController {
    var onComplete: (() -> Void)?
    var onCancel: (() -> Void)?

    private lazy var infoLabel = UILabel()
        .text("This is the child coordinator's screen.\n\nSwipe back to cancel the flow, or tap Complete to finish it.")
        .font(.systemFont(ofSize: 16))
        .textColor(.secondaryLabel)
        .textAlignment(.center)
        .numberOfLines(0)

    private lazy var completeButton = UIButton(
        configuration: .filled().with {
            $0.title = "Complete Flow"
            $0.cornerStyle = .capsule
            $0.image = UIImage(systemName: "checkmark.circle")
            $0.imagePadding = 6
        }
    )
    .onTap { [weak self] in self?.onComplete?() }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent { onCancel?() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Child Flow"
        view.backgroundColor(.systemBackground)
        buildUI()
    }

    private func buildUI() {
        let container = VStack(
            alignment: .center,
            margins: .init(top: 48, left: 24, bottom: 24, right: 24),
            spacing: 24
        ) {
            infoLabel
            completeButton
        }
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            completeButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
}
