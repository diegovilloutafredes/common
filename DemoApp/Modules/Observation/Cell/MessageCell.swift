//
//  MessageCell.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - MessageCell
/// No `viewModel didSet` here: assignment runs `updateContent()` synchronously, and a later
/// `isRead` change on the bound model re-runs it. A recycled cell bound to nil renders as an empty row.
final class MessageCell: BaseViewModelableCell<MessageItem> {
    /// Estimated height only: rows self-size to their preview text (see `preferredLayoutAttributesFitting`).
    static let height: Double = 56

    private lazy var unreadDot = UIView()
        .backgroundColor(.systemBlue)
        .setAsRoundedView()
        .setConstraints { $0.set(width: 10); $0.set(height: 10) }

    private lazy var senderLabel = UILabel()
        .textColor(.label)

    private lazy var previewLabel = UILabel()
        .font(.systemFont(ofSize: 13))
        .textColor(.secondaryLabel)
        .numberOfLines(0)

    @UIViewBuilder override var mainView: UIView {
        HStack(alignment: .center, margins: .init(horizontal: 16, vertical: 8), spacing: 12) {
            unreadDot
            VStack(spacing: 2) {
                senderLabel
                previewLabel
            }
        }
    }

    /// Self-sizing: measured right after `viewModel` is assigned, which is why assignment
    /// binds synchronously — a deferred bind would measure empty labels.
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        attributes.frame.size = contentView.systemLayoutSizeFitting(
            CGSize(width: layoutAttributes.size.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return attributes
    }

    override func updateContent() {
        // A nil model is a state to render: returning early would leave a recycled cell showing its last message.
        let isRead = viewModel?.isRead ?? true
        senderLabel
            .text(viewModel?.sender)
            .font(.systemFont(ofSize: 15, weight: isRead ? .regular : .semibold))
        previewLabel.text(viewModel?.preview)
        // alpha rather than isHidden: the row geometry never changes, a pure updateProperties-style change.
        unreadDot.alpha(isRead ? .zero : 1)
    }
}
