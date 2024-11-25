//
//  UIButton+Menu.swift
//

import UIKit

extension UIButton {
    @discardableResult public func menu(_ menu: UIMenu) -> Self {
        with {
            $0.menu = menu
            $0.showsMenuAsPrimaryAction = true
        }
    }
}
