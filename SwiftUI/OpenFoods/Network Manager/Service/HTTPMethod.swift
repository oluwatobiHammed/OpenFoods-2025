//
//  HTTPMethod.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import Foundation

/// A strongly typed representation of HTTP request methods.
///
/// Use `HTTPMethod` when constructing requests to avoid hard‑coding string
/// literals like `"GET"` or `"PUT"`. Each case’s `rawValue` maps directly to
/// the value expected by `URLRequest.httpMethod`.
///
/// Example:
/// ```swift
/// var request = URLRequest(url: url)
/// request.httpMethod = HTTPMethod.get.rawValue
/// ```
///
/// Semantics:
/// - Methods have standardized meanings defined by the HTTP specification.
/// - Some methods are considered “safe” (do not modify server state) and/or
///   “idempotent” (repeating the same request has the same effect).
///
/// Notes:
/// - The raw string values are uppercase to match the wire format.
/// - Extend this enum with additional cases (e.g., `post`, `delete`, `patch`)
///   as your API surface grows.
///
/// See also:
/// - RFC 9110: HTTP Semantics (Sections 9.x)
///
///
/// GET
/// ----
///
/// Fetches a representation of the target resource.
///
/// Characteristics:
/// - Safe: Yes
/// - Idempotent: Yes
/// - Request body: Typically not sent
///
/// Common uses:
/// - Retrieving data without side effects
///
///
/// PUT
/// ----
///
/// Creates or replaces the target resource with the request payload.
///
/// Characteristics:
/// - Safe: No
/// - Idempotent: Yes
/// - Request body: Required (the complete new representation)
///
/// Common uses:
/// - Full updates where the client sends the entire resource representation
/// - Resource creation at a known URI
public enum HTTPMethod : String {
    case get     = "GET"
    case put     = "PUT"
}
