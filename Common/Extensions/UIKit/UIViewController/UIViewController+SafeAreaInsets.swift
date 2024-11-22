//
//  UIViewController+SafeAreaInsets.swift
//

import UIKit

extension UIViewController {
    public var safeAreaInsets: UIEdgeInsets { UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero }
    public var safeAreaTopInset: CGFloat { safeAreaInsets.top }
    public var safeAreaBottomInset: CGFloat { safeAreaInsets.bottom }
    public var safeAreaLeftInset: CGFloat { safeAreaInsets.left }
    public var safeAreaRightInset: CGFloat { safeAreaInsets.right }
}
