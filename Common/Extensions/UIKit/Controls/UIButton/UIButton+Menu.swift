//
//  UIButton+Menu.swift
//

import UIKit

extension UIButton {
    
    /// Sets the menu for the button and enables it as the primary action.
    /// - Parameter menu: The menu to attach.
    @discardableResult public func menu(_ menu: UIMenu) -> Self {
        with {
            $0.menu = menu
            $0.showsMenuAsPrimaryAction = true
        }
    }
}
