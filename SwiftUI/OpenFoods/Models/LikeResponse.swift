//
//  LikeResponse.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-25.
//

/// Represents the backend’s response to a “like” (or “unlike”) request.
///
/// This lightweight model decodes a minimal payload that indicates whether the server
/// successfully recorded the requested action.
///
/// Conforms to `Codable` so it can be encoded to and decoded from JSON without
/// additional boilerplate.
///
/// JSON example:
/// ```json
/// { "success": true }
/// ```
///
/// Properties:
/// - `success`: A Boolean that is `true` when the server reports the like/unlike
///   operation succeeded, and `false` otherwise. Note that an API may still return an
///   HTTP 2xx status while setting `success` to `false` to indicate a domain-specific
///   failure.
///
/// Usage:
/// ```swift
/// let response = try JSONDecoder().decode(LikeResponse.self, from: data)
/// if response.success {
///     // The server recorded the like/unlike action
/// } else {
///     // Handle a logical failure reported by the backend
/// }
/// ```
struct LikeResponse: Codable {
    let success: Bool
}
