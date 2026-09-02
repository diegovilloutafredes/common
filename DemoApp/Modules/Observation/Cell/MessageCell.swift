//
//  MessageCell.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - MessageCell
/// No `viewModel didSet` here: assignment schedules `updateContent()`, and a later
/// `isRead` change on the bound model re-runs it.
final class MessageCell: BaseViewModelableCell<MessageItem> {
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

    @UIViewBuilder override var mainView: UIView {
        HStack(alignment: .center, margins: .init(horizontal: 16, vertical: 8), spacing: 12) {
            unreadDot
            VStack(spacing: 2) {
                senderLabel
                previewLabel
            }
        }
    }

    override func updateContent() {
        guard let viewModel else { return }
        senderLabel
            .text(viewModel.sender)
            .font(.systemFont(ofSize: 15, weight: viewModel.isRead ? .regular : .semibold))
        previewLabel.text(viewModel.preview)
        // alpha rather than isHidden: the row geometry never changes, a pure updateProperties-style change.
        unreadDot.alpha(viewModel.isRead ? .zero : 1)
    }
}
