//
//  DeclarativeUIViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - DeclarativeUIViewController
final class DeclarativeUIViewController: BaseViewModelableViewController<DeclarativeUIViewModelProtocol> {

    private lazy var headerLabel = UILabel()
        .text("@UIViewBuilder Demo")
        .font(.boldSystemFont(ofSize: 22))
        .textColor(.label)
        .textAlignment(.center)
        .numberOfLines(0)

    private lazy var vStackDemo = VStack(spacing: 8) {
        UILabel()
            .text("VStack (spacing: 8)")
            .font(.boldSystemFont(ofSize: 14))
            .textColor(.secondaryLabel)
        UIView()
            .backgroundColor(.systemBlue)
            .setConstraints { $0.set(height: 40) }
            .round(radius: 8)
        UIView()
            .backgroundColor(.systemGreen)
            .setConstraints { $0.set(height: 40) }
            .round(radius: 8)
        UIView()
            .backgroundColor(.systemOrange)
            .setConstraints { $0.set(height: 40) }
            .round(radius: 8)
    }
    .backgroundColor(.secondarySystemBackground)
    .round(radius: 12)
    .with { $0.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12) }

    private lazy var hStackDemo = HStack(spacing: 8) {
        UILabel()
            .text("HStack (spacing: 8)")
            .font(.boldSystemFont(ofSize: 14))
            .textColor(.secondaryLabel)
        UIView()
            .backgroundColor(.systemPurple)
            .setConstraints { $0.set(width: 40); $0.set(height: 40) }
            .round(radius: 8)
        UIView()
            .backgroundColor(.systemRed)
            .setConstraints { $0.set(width: 40); $0.set(height: 40) }
            .round(radius: 8)
        UIView()
            .backgroundColor(.systemYellow)
            .setConstraints { $0.set(width: 40); $0.set(height: 40) }
            .round(radius: 8)
    }
    .backgroundColor(.secondarySystemBackground)
    .round(radius: 12)
    .with { $0.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12) }

    private lazy var snapDemo: UIView = {
        let container = UIView()
            .backgroundColor(.secondarySystemBackground)
            .round(radius: 12)

        let label = UILabel()
            .text(".snap(to:) anchors to superview edges")
            .font(.systemFont(ofSize: 14))
            .textColor(.secondaryLabel)
            .textAlignment(.center)
            .numberOfLines(0)
            .setConstraints { $0.alignCenter(with: $1) }

        container.subviews { label }
        container.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return container
    }()

    @UIViewBuilder
    override var mainView: UIView {
        UIScrollView()
            .setConstraints { $0.snap(to: $1) }
            .with { scroll in
                let contentStack = VStack(
                    margins: .init(top: 16, left: 16, bottom: 32, right: 16),
                    spacing: 16
                ) {
                    headerLabel
                    vStackDemo
                    hStackDemo
                    snapDemo
                }
                contentStack.translatesAutoresizingMaskIntoConstraints = false
                scroll.addSubview(contentStack)
                NSLayoutConstraint.activate([
                    contentStack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
                    contentStack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
                    contentStack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
                    contentStack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
                    contentStack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
                ])
            }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemBackground)
    }
}
