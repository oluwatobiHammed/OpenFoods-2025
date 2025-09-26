//
//  HTTPTask.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import Foundation

/// Describes the type of work a router should perform to build an `URLRequest`.
///
/// `HTTPTask` is typically used by a networking layer (e.g., a Router) to determine:
/// - whether a request has a body,
/// - how parameters should be encoded,
/// - whether URL query parameters should be appended,
/// - and whether the request is expected to carry custom headers (provided externally).
///
/// See also:
/// - `ParameterEncoding` for how parameters are encoded into the `URLRequest`.
/// - `Parameters` for key/value parameter payloads (e.g., `[String: Any]`).
/// - `ArrayParameters` for top-level array payloads (e.g., `[[String: Any]]` or `[Any]`).
///
/// Usage guidance:
/// - Use `.request` for simple requests without parameters (e.g., a plain GET).
/// - Use `.requestParameters` when you need to send a body and/or URL query items.
/// - Use `.requestParametersAndHeaders` when you also intend to attach custom headers (provided elsewhere).
/// - Use `.requestArrayParametersAndHeaders` for endpoints that accept a top-level JSON array body along with optional URL query items and headers.
/// - Use `.requestHeaders` when you only need to send headers (no body or URL parameters), often to set `Content-Type` via `bodyEncoding`.
///
/// Notes:
/// - Cases with “AndHeaders” do not include headers as associated values; headers are expected to be supplied by the endpoint/router configuration.
/// - The `bodyEncoding` value commonly determines the `Content-Type` and how parameters are serialized (e.g., JSON vs. URL-encoded).
///
/// Example (conceptual):
///   // GET /users
///   task = .request
///
///   // GET /search?q=John&page=1
///   task = .requestParameters(bodyParameters: nil,
///                             bodyEncoding: .urlEncoding,
///                             urlParameters: ["q": "John", "page": 1])
///
///   // POST /users with JSON body and custom headers defined on the endpoint
///   task = .requestParametersAndHeaders(bodyParameters: ["name": "Jane"],
///                                       bodyEncoding: .jsonEncoding,
///                                       urlParameters: nil)
///
///   // POST /bulk with a top-level JSON array body
///   task = .requestArrayParametersAndHeaders(bodyParameters: [["id": 1], ["id": 2]],
///                                            bodyEncoding: .jsonEncoding,
///                                            urlParameters: nil)
///
///   // HEAD /ping with only headers (e.g., custom auth) and no parameters
///   task = .requestHeaders(bodyEncoding: .jsonEncoding)
///
///
///
/// A plain request with no body or URL parameters.
///
/// Use for simple endpoints (e.g., `GET /status`) where no additional data is required.
///// case request
///
/// A request with optional body parameters and/or URL query parameters.
///
/// - Parameters:
///   - bodyParameters: Key–value pairs to encode into the HTTP body (e.g., JSON or form URL-encoded), or `nil` if no body is needed.
///   - bodyEncoding: The strategy describing how to encode `bodyParameters` and/or `urlParameters` into the `URLRequest`.
///   - urlParameters: Key–value pairs to append to the URL as query items, or `nil` if no query is needed.
///
/// Use when you need to send either a body, query parameters, or both.
///// case requestParameters(bodyParameters: Parameters?, bodyEncoding: ParameterEncoding, urlParameters: Parameters?)
///
/// A request with optional body and/or URL parameters, intended to also carry custom headers.
///
/// - Parameters:
///   - bodyParameters: Key–value pairs to encode into the HTTP body, or `nil`.
///   - bodyEncoding: The strategy describing how to encode parameters into the `URLRequest`.
///   - urlParameters: Key–value pairs to append to the URL as query items, or `nil`.
///
/// Notes:
/// - Headers are not passed as associated values here; they are expected to be provided by the endpoint/router (e.g., a `headers` property).
///
/// Use when parameters are present and the endpoint requires additional headers.
///// case requestParametersAndHeaders(bodyParameters: Parameters?, bodyEncoding: ParameterEncoding, urlParameters: Parameters?)
///
/// A request whose body is a top-level array, with optional URL parameters, intended to also carry custom headers.
///
/// - Parameters:
///   - bodyParameters: An array payload to encode at the root of the HTTP body (e.g., a JSON array), or `nil`.
///   - bodyEncoding: The strategy describing how to encode the array body and/or URL parameters.
///   - urlParameters: Key–value pairs to append to the URL as query items, or `nil`.
///
/// Notes:
/// - Use this when the API expects a top-level JSON array rather than a dictionary/object.
/// - Headers are provided externally by the endpoint/router configuration.
///
/// Use for bulk operations (e.g., posting an array of items).
///// case requestArrayParametersAndHeaders(bodyParameters: ArrayParameters?, bodyEncoding: ParameterEncoding, urlParameters: Parameters?)
///
/// A request that only carries headers (no body or URL parameters).
///
/// - Parameters:
///   - bodyEncoding: The encoding strategy which may be used to set related header fields (e.g., `Content-Type`).
///
/// Use when you need to perform a request where only headers matter (e.g., HEAD requests, token refresh preflight), and no parameters are required.
///// case requestHeaders(bodyEncoding: ParameterEncoding)
public enum HTTPTask {
    case request
    
    case requestParameters(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?)
    
    case requestParametersAndHeaders(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?)
    
    case requestArrayParametersAndHeaders(bodyParameters: ArrayParameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?)
    
    case requestHeaders(bodyEncoding: ParameterEncoding)
    

}
