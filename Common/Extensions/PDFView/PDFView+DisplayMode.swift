//
//  PDFView+DisplayMode.swift
//

import PDFKit

extension PDFView {
    
    /// Sets the display mode of the PDF view and returns self (chainable).
    /// - Parameter displayMode: The display mode (e.g., single page, two up).
    @discardableResult public func displayMode(_ displayMode: PDFDisplayMode) -> Self {
        with { $0.displayMode = displayMode }
    }
}
