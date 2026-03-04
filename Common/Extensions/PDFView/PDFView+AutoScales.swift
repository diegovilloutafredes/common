//
//  PDFView+AutoScales.swift
//

import PDFKit

extension PDFView {
    
    /// Sets whether the PDF view should auto-scale the document and returns self (chainable).
    /// - Parameter autoScales: `true` to enable auto-scaling.
    @discardableResult public func autoScales(_ autoScales: Bool) -> Self {
        with { $0.autoScales = autoScales }
    }
}
