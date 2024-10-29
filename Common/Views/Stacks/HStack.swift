//
//  HStack.swift
//

import UIKit

// MARK: - HStack
public final class HStack: Stack {
    public init(
        alignment: Alignment = .fill,
        distribution: Distribution = .fill,
        margins: UIEdgeInsets = .zero,
        spacing: CGFloat = .zero,
        @UIViewsBuilder views: () -> [UIView] = {[]}
    ) {
        super.init()
        horizontal(alignment: alignment, distribution: distribution, margins: margins, spacing: spacing)
        self.views(views)
    }
}
