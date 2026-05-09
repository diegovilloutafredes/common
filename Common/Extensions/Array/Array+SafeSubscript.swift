//
//  Array+SafeSubscript.swift
//

extension Array {

    /// Returns the element at the given index, or `nil` if the index is out of bounds.
    public subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
