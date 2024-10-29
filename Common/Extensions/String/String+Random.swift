//
//  String+Random.swift
//

extension String {
    public static func random(length: Int) -> String {
        .init((0..<length).compactMap { _ in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement() })
    }
}
