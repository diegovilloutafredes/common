//
//  BaseDNITextField.swift
//

// MARK: - BaseDNITextField
open class BaseDNITextField: BaseTextField {
    open override func setupView() {
        allowedChars("0123456789kK")
        .maxLength(9)
        .onEditingDidBegin { $0.text($0.text?.removeRUTFormat()) }
        .onEditingDidEnd { $0.text($0.text?.formatAsRUT()) }
    }
}
