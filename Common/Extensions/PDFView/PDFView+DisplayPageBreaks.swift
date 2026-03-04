//
//  PDFView+DisplayPageBreaks.swift
//

import PDFKit

extension PDFView {
    
    /// Sets whether page breaks should be displayed and returns self (chainable).
    /// - Parameter displaysPageBreaks: `true` to show page breaks.
    @discardableResult public func displaysPageBreaks(_ displaysPageBreaks: Bool) -> Self {
        with { $0.displaysPageBreaks = displaysPageBreaks }
    }
}
