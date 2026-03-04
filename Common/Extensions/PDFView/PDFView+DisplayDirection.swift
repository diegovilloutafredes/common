//
//  PDFView+DisplayDirection.swift
//

import PDFKit

extension PDFView {
    
    /// Sets the display direction of the PDF view and returns self (chainable).
    /// - Parameter displayDirection: The direction (vertical or horizontal).
    @discardableResult public func displayDirection(_ displayDirection: PDFDisplayDirection) -> Self {
        with { $0.displayDirection = displayDirection }
    }
}
