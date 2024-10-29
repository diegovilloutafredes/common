//
//  ArrayBuilder.swift
//

// MARK: - ArrayBuilder
@resultBuilder
public struct ArrayBuilder<T> {
    public static func buildBlock(_ items: T...) -> [T] { items }
    public static func buildBlock(_ items: [T]...) -> [T] { items.flatMap { $0 } }
    public static func buildEither(first item: [T]) -> [T] { item }
    public static func buildEither(second item: [T]) -> [T] { item }
    public static func buildExpression(_ item: T) -> [T] { [item] }
    public static func buildExpression(_ item: [T]) -> [T] { item }
    public static func buildOptional(_ items: [T]?) -> [T] { items ?? [] }
}
