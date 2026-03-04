//
//  PDFView+Document.swift
//

import PDFKit

extension PDFView {
    
    /// Sets the document to be displayed and returns self (chainable).
    /// - Parameter document: The PDF document.
    @discardableResult public func document(_ document: PDFDocument?) -> Self {
        with { $0.document = document }
    }
}
