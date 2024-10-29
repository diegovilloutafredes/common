//
//  UIViewController+SafeAreaInsets.swift
//

import UIKit

extension UIViewController {
    var safeAreaInsets: UIEdgeInsets { UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero }
    var safeAreaTopInset: CGFloat { UIApplication.shared.keyWindow?.safeAreaInsets.top ?? .zero }
    var safeAreaBottomInset: CGFloat { UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? .zero }
    var safeAreaLeftInset: CGFloat { UIApplication.shared.keyWindow?.safeAreaInsets.left ?? .zero }
    var safeAreaRightInset: CGFloat { UIApplication.shared.keyWindow?.safeAreaInsets.right ?? .zero }
}
