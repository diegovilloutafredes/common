//
//  UnreadBadgeView.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - UnreadBadgeView
/// A `BaseView` that renders itself from observable models in `updateContent()`.
///
/// Rows are read through a closure rather than held: the `isRead` reads inside the hook are
/// tracked wherever they happen, and the owner re-fetches the current rows after a membership
/// change by calling `setNeedsContentUpdate()` (the array itself is not observable).
final class UnreadBadgeView: BaseView {
    private let messages: () -> [MessageItem]

    private lazy var label = UILabel()
        .font(.systemFont(ofSize: 15, weight: .semibold))
        .textColor(.white)
        .textAlignment(.center)
        .setConstraints { $0.set(height: 36) }

    private lazy var container = VStack(margins: .init(all: 12)) { label }
        .round(radius: 8)

    init(messages: @escaping () -> [MessageItem]) {
        self.messages = messages
        super.init()
    }

    @UIViewBuilder override var mainView: UIView { container }

    override func updateContent() {
        let unread = messages().filter { !$0.isRead }.count
        label.text("\(unread) unread")
        container.backgroundColor(unread == .zero ? .systemGreen : .systemRed)
    }
}
