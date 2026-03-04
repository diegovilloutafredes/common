//
//  BaseDNITextField.swift
//

// MARK: - BaseDNITextField
// MARK: - BaseDNITextField

/// A specialized text field for DNI (National Identification Document) input.
/// It automatically handles RUT formatting and restricted characters (`0-9`, `k`, `K`).
open class BaseDNITextField: BaseTextField {
    open override func setupView() {
        allowedChars("0123456789kK")
        .maxLength(9)
        .onEditingDidBegin { $0.text($0.text?.removeRUTFormat()) }
        .onEditingDidEnd { $0.text($0.text?.formatAsRUT()) }
    }
}
