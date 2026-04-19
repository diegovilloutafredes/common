//
//  ArrayBuilder.swift
//

// MARK: - ArrayBuilder
/// A result builder that constructs an array of elements from a closure.
@resultBuilder
public struct ArrayBuilder<T> {

    /// Builds a block of partial results into a single array.
    public static func buildBlock(_ items: T...) -> [T] { items }

    /// Builds a block of partial results into a single array.
    public static func buildBlock(_ items: [T]...) -> [T] { items.flatMap { $0 } }

    /// Builds an array for a conditional statement that evaluates to the first branch.
    public static func buildEither(first item: [T]) -> [T] { item }

    /// Builds an array for a conditional statement that evaluates to the second branch.
    public static func buildEither(second item: [T]) -> [T] { item }

    /// Builds an array from a single expression.
    public static func buildExpression(_ item: T) -> [T] { [item] }

    /// Builds an array from an array expression.
    public static func buildExpression(_ item: [T]) -> [T] { item }

    /// Builds an array from an optional result.
    public static func buildOptional(_ items: [T]?) -> [T] { items ?? [] }

    /// Supports `for item in collection { ... }` inside result builder closures.
    public static func buildArray(_ components: [[T]]) -> [T] { components.flatMap { $0 } }

    /// Supports `if #available(iOS X, *) { ... }` inside result builder closures.
    public static func buildLimitedAvailability(_ component: [T]) -> [T] { component }
}
