//
//  UnreadBadgeView.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - UnreadBadgeView
/// A `BaseView` that renders itself from observable models in `updateContent()`.
final class UnreadBadgeView: BaseView {
    private let messages: [MessageItem]

    private lazy var label = UILabel()
        .font(.systemFont(ofSize: 15, weight: .semibold))
        .textColor(.white)
        .textAlignment(.center)
        .setConstraints { $0.set(height: 36) }

    private lazy var container = VStack(margins: .init(all: 12)) { label }
        .round(radius: 8)

    init(messages: [MessageItem]) {
        self.messages = messages
        super.init()
    }

    @UIViewBuilder override var mainView: UIView { container }

    override func updateContent() {
        let unread = messages.filter { !$0.isRead }.count
        label.text("\(unread) unread")
        container.backgroundColor(unread == .zero ? .systemGreen : .systemRed)
    }
}
