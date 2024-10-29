//
//  UIPickerView+DataSource.swift
//

import UIKit

extension UIPickerView {
    @discardableResult public func dataSource(_ dataSource: UIPickerViewDataSource) -> Self {
        with { $0.dataSource = dataSource }
    }
}
