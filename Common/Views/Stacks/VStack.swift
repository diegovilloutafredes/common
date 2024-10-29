//
//  VStack.swift
//

import UIKit

// MARK: - VStack
public final class VStack: Stack {
    public init(
        alignment: Alignment = .fill,
        distribution: Distribution = .fill,
        margins: UIEdgeInsets = .zero,
        spacing: CGFloat = .zero,
        @UIViewsBuilder views: () -> [UIView] = {[]}
    ) {
        super.init()
        vertical(alignment: alignment, distribution: distribution, margins: margins, spacing: spacing)
        self.views(views)
    }
}
