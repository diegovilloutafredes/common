//
//  MirrorDescribable.swift
//

// MARK: - MirrorDescribable
/// A type whose `description` lists its stored properties as `label: value`, one per line, in declaration order.
///
/// Adopt it instead of writing `description` by hand:
/// ```swift
/// struct Item: MirrorDescribable {
///     let name: String
///     let count: Int
/// }
///
/// "\(Item(name: "a", count: 2))"   // "name: a\ncount: 2"
/// ```
/// A type that implements `description` itself keeps its own.
public protocol MirrorDescribable: CustomStringConvertible {}

// MARK: - Default implementation
extension MirrorDescribable {
    public var description: String { mirrorDescription(of: self) }
}

/// The children of `subject`'s mirror as `label: value`, one per line, with "No label" for a child that has none.
/// `MirrorDescribable` and the deprecated default for every `CustomStringConvertible` share it, so they can't drift.
func mirrorDescription(of subject: Any) -> String {
    Mirror(reflecting: subject)
        .children
        .map { "\($0.label ?? "No label"): \($0.value)" }
        .joined(separator: "\n")
}
