//
//  EmptyResponse.swift
//

import Foundation

// MARK: - EmptyResponse

/// The response type of a request whose success carries no body, such as a 204 or a DELETE.
///
/// A 2xx response requested as `EmptyResponse` succeeds without its body being decoded, whether the body is empty or
/// not. Any other type still needs a body: an empty 2xx body requested as a model fails with
/// `NetworkError.decodingError`. Error responses fail as they do for any type.
///
/// ```swift
/// func delete(id: String) async throws {
///     let _: EmptyResponse = try await request(ProductRouter.delete(id))
/// }
/// ```
///
/// As a field inside a decoded envelope, it decodes whatever the field holds.
public struct EmptyResponse: Decodable, Equatable, Sendable {

    /// Creates an empty response.
    public init() {}

    /// Decodes nothing, whatever the value holds.
    public init(from decoder: Decoder) throws {}
}
