//
//  UIViewController+SafeAreaInsets.swift
//

import UIKit

extension UIViewController {
    
    /// Returns the key window's safe area insets.
    public var safeAreaInsets: UIEdgeInsets { UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero }
    
    /// Returns the top safe area inset.
    public var safeAreaTopInset: CGFloat { safeAreaInsets.top }
    
    /// Returns the bottom safe area inset.
    public var safeAreaBottomInset: CGFloat { safeAreaInsets.bottom }
    
    /// Returns the left safe area inset.
    public var safeAreaLeftInset: CGFloat { safeAreaInsets.left }
    
    /// Returns the right safe area inset.
    public var safeAreaRightInset: CGFloat { safeAreaInsets.right }
}
