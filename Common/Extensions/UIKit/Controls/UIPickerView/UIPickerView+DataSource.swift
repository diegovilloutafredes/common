//
//  UIPickerView+DataSource.swift
//

import UIKit

extension UIPickerView {
    
    /// Sets the data source and returns self (chainable).
    /// - Parameter dataSource: The data source to set.
    @discardableResult public func dataSource(_ dataSource: UIPickerViewDataSource) -> Self {
        with { $0.dataSource = dataSource }
    }
}
