//
//  Router.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import Foundation


/// An enumeration that models common outcomes of a network request with
/// user‑friendly, displayable messages.
///
/// Use `NetworkResponse` to normalize status handling across the networking
/// layer. The `rawValue` for each error case is a preformatted, human‑readable
/// message intended for presentation in UI or logging.
///
/// In this project, `NetworkResponse` is primarily produced by
/// `Router.handleNetworkResponse(_:)` and may also be surfaced as part of the
/// error returned from `Router.request(_:)`.
///
/// Cases:
/// - success:
///   The request completed successfully (typically HTTP 2xx).
///
/// - authenticationError:
///   Authentication is required or failed (e.g., HTTP 401–403).
///   Raw value provides a user‑readable explanation.
///
/// - badRequest:
///   The server could not process the request due to a client or request
///   formatting error. Note: In this codebase, some 5xx responses are also
///   mapped to this case. Raw value provides a user‑readable explanation.
///
/// - outdated:
///   The requested URL or endpoint is considered outdated or unsupported by
///   the backend (mapped here to an unconventional HTTP 600 code in
///   `handleNetworkResponse`). Raw value provides a user‑readable explanation.
///
/// - failed:
///   A general networking failure occurred (e.g., connectivity issues, timeouts,
///   or unexpected status codes not otherwise handled). Raw value provides a
///   user‑readable explanation.
///
/// - noData:
///   The response did not include a body to decode. Raw value provides a
///   user‑readable explanation.
///
/// - unableToDecode:
///   The response body could not be decoded into the expected model type.
///   Raw value provides a user‑readable explanation.
///
/// - unableToConvertToImage:
///   The response data could not be converted into an image object. Raw value
///   provides a user‑readable explanation.
///
/// See also:
/// - `Router.handleNetworkResponse(_:)`
/// - `Router.request(_:)`
enum NetworkResponse:String, Error {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
    case unableToConvertToImage = "We could not convert response data to image."
}


/// A minimal, generic two-state result type used to express success or failure
/// without carrying a success value.
///
/// Overview:
/// - `Result` models the outcome of an operation that either succeeds (with no
///   additional information) or fails with an associated error value.
/// - This is useful when you only need to know whether something succeeded or
///   failed, and you do not need to return a value on success.
///
/// Type Parameters:
/// - Error: The type of the error associated with the `.failure` case. This can
///   be any error type (e.g., conforming to `Swift.Error`), such as `NSError`,
///   custom error enums, or domain-specific error types.
///
/// Cases:
/// - success:
///   Indicates the operation completed successfully. This case carries no
///   associated value.
/// - failure(Error):
///   Indicates the operation failed with the provided error value.
///
/// Usage:
/// ```swift
/// // Declare a result that can fail with any Error-conforming type.
/// let result: Result<Swift.Error> = .success
///
/// switch result {
/// case .success:
///     // Handle successful completion
///     print("Operation succeeded.")
/// case .failure(let error):
///     // Handle failure
///     print("Operation failed with error: \(error)")
/// }
/// ```
///
/// Discussion:
/// - Unlike `Swift.Result<Success, Failure>`, this type does not carry a success
///   value; it only indicates success or provides an error on failure. Use this
///   when the success path does not need to return data.
/// - If you need to return a value on success, prefer the standard library's
///   `Swift.Result<Success, Failure>`.
/// - The generic parameter is named `Error` here for convenience, but it is not
///   constrained to `Swift.Error`. For clarity, consider using types that
///   conform to `Swift.Error`.
///
/// See Also:
/// - `Swift.Result` (standard library): A more expressive alternative that
///   carries a success value along with a failure type.
enum Result<Error>{
    case success
    case failure(Error)
}



/// A lightweight protocol that abstracts a networking “router” capable of
/// building and executing requests for a specific set of API endpoints.
///
/// Overview:
/// - `NetworkRouter` decouples request execution from endpoint description. You
///   provide an `EndPoint` that describes the request (base URL, path, method,
///   parameters), and a conforming router performs the request asynchronously,
///   returning the raw `Data?`, `URLResponse?`, and an `Error?`.
/// - In this project, `Router<EndPoint>` is the concrete implementation used by
///   feature layers to call the network.
///
/// Associated Types:
/// - `EndPoint`: A type that conforms to `EndPointType` and describes a single
///   API operation (e.g., `baseURL`, `path`, `httpMethod`, and parameter
///   encoding).
///
/// Concurrency and Cancellation:
/// - The `request(_:)` function is `async`. Implementations that use
///   `URLSession.data(for:)` automatically cooperate with Swift concurrency and
///   support structured task cancellation (cancelling the parent `Task` cancels
///   the in-flight request).
///
/// Error Handling:
/// - The method does not throw. Instead, it returns an `Error?` as the third
///   element of the tuple. This error can represent:
///   - Transport or decoding issues surfaced by the underlying system, or
///   - Domain-specific errors derived from HTTP status codes and/or response
///     bodies (e.g., via `Router.handleNetworkResponse(_:)` or generic parsing).
/// - A non-`nil` error does not guarantee that `data` is `nil`. Servers may
///   return an error payload alongside a non-success status code. Callers should
///   inspect all tuple elements (`data`, `response`, and `error`) to decide how
///   to proceed.
///
/// Thread Safety:
/// - The protocol itself does not prescribe thread-safety. Concrete
///   implementations should document their own guarantees if shared across
///   threads.
///
/// Usage Example:
/// ```swift
/// // Assume `MyAPI` conforms to EndPointType.
/// let router = Router<MyAPI>()
/// let (data, response, error) = await router.request(.getUsers)
///
/// if let error {
///     // Handle transport or server-side error (may still have `data`)
/// }
///
/// if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
///     // Success path; decode `data` as needed
/// }
/// ```
///
/// See also:
/// - `Router` (project’s concrete implementation)
/// - `EndPointType` (endpoint description contract)
/// - `NetworkResponse` (common, user‑friendly error mapping)
///
/// - Parameter route: The endpoint that describes the request to perform.
/// - Returns: A tuple containing:
///   - `Data?`: The response body, if present.
///   - `URLResponse?`: The URL loading system’s response (often `HTTPURLResponse`).
///   - `Error?`: A transport or mapped domain error, or `nil` on success.
protocol NetworkRouter: AnyObject {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint) async -> (Data?,URLResponse?, Error?)
}

class Router<EndPoint: EndPointType>: NetworkRouter {

    private let session = URLSession(configuration: .default)
    private var task: URLSessionTask?
    
    /// Performs the network request described by the given endpoint and returns the raw response components.
    ///
    /// Overview:
    /// - Builds a `URLRequest` from the supplied `route`, logs it, and executes it asynchronously using `URLSession.data(for:)`.
    /// - Normalizes errors into the third element of the returned tuple:
    ///   - Transport/build errors are caught and surfaced as the `Error?`.
    ///   - For HTTP responses, non-2xx status codes are mapped into a domain error using `parseGenericError(from:statusCode:)`.
    ///   - If the response cannot be interpreted as `HTTPURLResponse`, a generic error is produced via `handleNetworkResponse(_:)`.
    ///
    /// Concurrency & Cancellation:
    /// - This method is `async` and cooperates with Swift concurrency. Cancelling the surrounding `Task` will cancel the in-flight request.
    /// - No explicit callback queues are used; callers should hop to the main actor if they need to update UI.
    ///
    /// Error Semantics:
    /// - The method does not throw; instead, it returns any error in the third tuple position.
    /// - A non-`nil` error does not imply `data` is `nil`. Servers may return error payloads alongside non-success status codes.
    /// - For non-2xx HTTP responses, `parseGenericError(from:statusCode:)` attempts to extract a user-readable message from JSON or raw text.
    ///
    /// - Parameter route: The endpoint that describes the request to perform. Must conform to `EndPointType`.
    /// - Returns: A tuple `(Data?, URLResponse?, Error?)` where:
    ///   - `Data?`: The response body, if present.
    ///   - `URLResponse?`: The URL loading system’s response (typically an `HTTPURLResponse`).
    ///   - `Error?`: A transport or mapped domain error, or `nil` on success.
    ///
    /// Usage:
    /// ```swift
    /// let router = Router<MyAPI>()
    /// let (data, response, error) = await router.request(.getUsers)
    ///
    /// if let error {
    ///     // Handle transport or server-side error (may still have `data`)
    /// }
    ///
    /// if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
    ///     // Decode `data` as needed
    /// }
    /// ```
    ///
    /// Notes:
    /// - Logging: The constructed request is logged via `NetworkLogger.log(request:)`.
    /// - Building: Requests are constructed with `buildRequest(from:)`, including parameter encoding as defined by the endpoint.
    /// - Mapping: HTTP status handling and message mapping are centralized in `parseGenericError(from:statusCode:)` and `handleNetworkResponse(_:)`.
    ///
    /// See Also:
    /// - `EndPointType`
    /// - `NetworkLogger.log(request:)`
    /// - `buildRequest(from:)`
    /// - `parseGenericError(from:statusCode:)`
    /// - `handleNetworkResponse(_:)`
    func request(_ route: EndPoint) async -> (Data?,URLResponse?, Error?) {
        
        do {
            
            let request = try buildRequest(from: route)
            NetworkLogger.log(request: request)
            let (data, response) = try await session.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                return (nil, nil, handleNetworkResponse(HTTPURLResponse()))
                }
            return (data, response, parseGenericError(from: data, statusCode: response.statusCode))
        } catch {
           return (nil, nil, error)
        }
    }
    
  
    
    // Generic function to parse any error from the response body
    /// Parses server‑provided error information from a non‑2xx HTTP response into a user‑readable `Error`.
    ///
    /// Overview:
    /// - Use this helper to convert an API’s error payload into a single, displayable `NSError`.
    /// - When the HTTP status code indicates success (200–299) or no response body is present,
    ///   the function returns `nil`, signaling “no error”.
    /// - For non‑success status codes with a body:
    ///   - Attempts to parse the body as JSON and, if it is a dictionary (`[String: Any]`),
    ///     concatenates `key: value` pairs into a single message.
    ///   - If the body is not a JSON dictionary but is valid UTF‑8 text, returns that text as the message.
    ///   - Otherwise, returns a generic “Unknown error occurred” message.
    /// - If JSON parsing throws, the raw UTF‑8 text (if any) is used as a fallback; if that fails,
    ///   “Invalid error format” is used.
    ///
    /// Parameters:
    /// - data: The raw response body returned by the server (may be `nil`).
    /// - statusCode: The HTTP status code associated with the response.
    ///
    /// Returns:
    /// - `nil` if `statusCode` is in `200...299` or `data` is `nil`.
    /// - An `NSError` (domain: `"APIError"`, code: `statusCode`) whose
    ///   `NSLocalizedDescriptionKey` contains a human‑readable message derived from the body.
    ///
    /// Behavior Details:
    /// - JSON Dictionary: Builds a message by joining each `key: value` pair with “, ”.
    /// - Non‑Dictionary JSON (e.g., arrays, numbers): Falls back to interpreting the body as UTF‑8 text.
    /// - Non‑UTF‑8 or Unparseable Body: Returns a generic message indicating the format is unknown/invalid.
    ///
    /// Thread Safety:
    /// - Pure function with no side effects; safe to call from any thread.
    ///
    /// See Also:
    /// - `handleNetworkResponse(_:)` for status‑code‑only mapping when no body is available.
    /// - `request(_:)` for how this function is integrated into the request lifecycle.
    ///
    /// Example:
    /// ```swift
    /// if let error = parseGenericError(from: data, statusCode: httpResponse.statusCode) {
    ///     // Present error.localizedDescription to the user or log it
    /// }
    /// ```
    private func parseGenericError(from data: Data?, statusCode: Int) -> Error? {
        guard let data, !(200...299).contains(statusCode) else {
            return nil
        }
        
        do {
            // Attempt to parse the data as JSON
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let errorMessage = json.compactMap { "\($0.key): \($0.value)" }.joined(separator: ", ")
                return NSError(domain: "APIError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            } else if let rawMessage = String(data: data, encoding: .utf8) {
                // If it's not a JSON object, treat the data as a raw string
                return NSError(domain: "APIError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: rawMessage])
            } else {
                return NSError(domain: "APIError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
            }
        } catch {
            // If parsing fails, return the raw data as a fallback
            let rawMessage = String(data: data, encoding: .utf8) ?? "Invalid error format"
            return NSError(domain: "APIError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: rawMessage])
        }
    }
    
    
    
    /// Maps an HTTP response status code to a user‑facing error, or `nil` for “no error”.
    ///
    /// Overview:
    /// - This helper turns broad classes of HTTP status codes into standardized, display‑ready
    ///   `NSError` values using `NetworkResponse` messages.
    /// - It does not inspect the response body; only the status code is considered.
    /// - For more detailed error messages derived from a server‑provided body, prefer
    ///   `parseGenericError(from:statusCode:)`.
    ///
    /// Status‑Code Mapping:
    /// - 200...299 → `nil` (treated as success)
    /// - 404 → `nil` (intentionally not treated as an error by this helper; callers may handle 404 explicitly)
    /// - 401...500 → `authenticationError` (“You need to be authenticated first.”)
    /// - 501...599 → `badRequest` (“Bad request”) [Note: This project maps 5xx to a client‑facing message]
    /// - 600 → `outdated` (“The url you requested is outdated.”)
    /// - default → `failed` (“Network request failed.”)
    ///
    /// Error Construction:
    /// - Returns an `NSError` with:
    ///   - `domain`: `""` (empty string)
    ///   - `code`: `response.statusCode`
    ///   - `userInfo[NSLocalizedDescriptionKey]`: The corresponding `NetworkResponse` message
    ///
    /// When to Use:
    /// - Use as a lightweight, status‑only fallback when you don’t have or don’t need to parse a response body.
    /// - Combine with `parseGenericError(from:statusCode:)` when you want to surface server‑provided details.
    ///
    /// Thread Safety:
    /// - Pure function with no side effects; safe to call from any thread.
    ///
    /// Parameters:
    /// - response: The `HTTPURLResponse` whose status code will be evaluated.
    ///
    /// Returns:
    /// - `nil` for success (2xx) and for 404 (by project convention).
    /// - An `NSError` describing the failure for all other handled ranges.
    ///
    /// Example:
    /// ```swift
    /// if let http = response as? HTTPURLResponse,
    ///    let error = handleNetworkResponse(http) {
    ///     // Present error.localizedDescription or log it
    /// } else {
    ///     // Proceed as success
    /// }
    /// ```
    ///
    /// See Also:
    /// - `parseGenericError(from:statusCode:)`
    /// - `NetworkResponse`
    /// - `request(_:)`
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Error?{
        switch response.statusCode {
        case 200...299: break
        case 404: break
        case 401...500: return  NSError(
            domain: "",
            code: response.statusCode,
            userInfo: [NSLocalizedDescriptionKey : NetworkResponse.authenticationError.rawValue]
        )
        case 501...599: return  NSError(
            domain: "",
            code: response.statusCode,
            userInfo: [NSLocalizedDescriptionKey : NetworkResponse.badRequest.rawValue]
        )
        case 600: return  NSError(
            domain: "",
            code: response.statusCode,
            userInfo: [NSLocalizedDescriptionKey : NetworkResponse.outdated.rawValue]
        )
        default: return   NSError(
            domain: "",
            code: response.statusCode,
            userInfo: [NSLocalizedDescriptionKey : NetworkResponse.failed.rawValue]
        )
        }
        return nil
    }

    
    /// Builds a `URLRequest` from the provided endpoint description and applies the
    /// appropriate HTTP method and parameter encoding strategy.
    ///
    /// Overview:
    /// - Composes a `URLRequest` using `route.baseURL` + `route.path`, a cache policy
    ///   of `.reloadIgnoringLocalAndRemoteCacheData`, and a 12‑second timeout.
    /// - Sets the HTTP method from `route.httpMethod`.
    /// - Applies additional configuration based on `route.task`, delegating to the
    ///   endpoint’s `ParameterEncoding` to encode body, array body, and/or URL
    ///   parameters as needed.
    /// - For `.request`, it sets the `Content-Type` header to `application/json`.
    ///
    /// Behavior by Task:
    /// - `.request`:
    ///   - Sets `Content-Type: application/json`.
    /// - `.requestParameters(bodyParameters:bodyEncoding:urlParameters:)`:
    ///   - Encodes body and/or URL parameters using `bodyEncoding`.
    /// - `.requestParametersAndHeaders(bodyParameters:bodyEncoding:urlParameters:)`:
    ///   - Encodes body and/or URL parameters using `bodyEncoding`.
    ///   - Note: Header handling is expected to be performed by the encoding
    ///     strategy or elsewhere in the stack.
    /// - `.requestArrayParametersAndHeaders(bodyArrayParameters:bodyEncoding:urlParameters:)`:
    ///   - Encodes an array body and/or URL parameters using `bodyEncoding`.
    /// - `.requestHeaders(bodyEncoding:)`:
    ///   - Invokes the provided `bodyEncoding` to allow header/query configuration
    ///     without body parameters.
    ///
    /// Concurrency & Thread Safety:
    /// - Pure builder function; performs no network I/O and is safe to call from any thread.
    ///
    /// - Parameter route: The endpoint that defines the base URL, path, HTTP method,
    ///   and parameter/encoding strategy. Must conform to `EndPointType`.
    ///
    /// - Returns: A fully configured `URLRequest` ready to be executed by `URLSession`.
    ///
    /// - Throws: Any error thrown by the underlying `ParameterEncoding.encode(...)`
    ///   calls during parameter or header encoding (e.g., serialization failures).
    ///
    /// Example:
    /// ```swift
    /// let request = try buildRequest(from: route)
    /// let (data, response) = try await urlSession.data(for: request)
    /// ```
    ///
    /// See Also:
    /// - `EndPointType`
    /// - `ParameterEncoding`
    /// - `Parameters`
    /// - `ArrayParameters`
    fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {
        
        
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 12)
        
        request.httpMethod = route.httpMethod.rawValue
        
        do {
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
            case .requestParameters(let bodyParameters,
                                    let bodyEncoding,
                                    let urlParameters):
                
                try configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
                
            case .requestParametersAndHeaders(let bodyParameters,
                                              let bodyEncoding,
                                              let urlParameters):
                
              
                try configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
                
            case .requestArrayParametersAndHeaders(let bodyArrayParameters,
                                              let bodyEncoding,
                                              let urlParameters):
                
              
                try configureArrayParameters(bodyArrayParameters: bodyArrayParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
                
                
                
            case .requestHeaders(let bodyEncoding):
                
                
                try configureParameters(bodyParameters: nil,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: nil,
                                             request: &request)
     
            }
            return request
        } catch {
            throw error
        }
    }
    
    
    /// Encodes body and/or URL (query) parameters into the given `URLRequest` using the supplied encoding strategy.
    /// 
    /// Overview:
    /// - This helper is a thin wrapper around `ParameterEncoding.encode(...)`.
    /// - It mutates `request` in place to:
    ///   - Attach an HTTP body from `bodyParameters` when the encoding supports it (e.g., JSON or form-data).
    ///   - Append `urlParameters` to the request URL as a query string when applicable.
    ///   - Set or update any headers required by the chosen `bodyEncoding` (e.g., `Content-Type`).
    ///
    /// Behavior:
    /// - If both `bodyParameters` and `urlParameters` are `nil`, this function is effectively a no-op.
    /// - The exact serialization format (JSON, URL-encoded, etc.) and header configuration are delegated to `bodyEncoding`.
    /// - Any error thrown by the encoding process is propagated to the caller unchanged.
    ///
    /// Parameters:
    /// - bodyParameters: A dictionary of parameters to encode into the HTTP body. Pass `nil` to omit a body.
    /// - bodyEncoding: The `ParameterEncoding` strategy that performs the actual encoding and header configuration.
    /// - urlParameters: A dictionary of parameters to encode into the URL’s query component. Pass `nil` to omit query items.
    /// - request: The `URLRequest` to be mutated with encoded parameters and any headers required by the encoding strategy.
    ///
    /// Throws:
    /// - Rethrows any error produced by `bodyEncoding.encode(...)`, such as serialization or encoding failures.
    ///
    /// Side Effects:
    /// - Mutates `request` in place (HTTP body, URL, and/or headers).
    ///
    /// Thread Safety:
    /// - Pure helper with respect to global state; safe to call from any thread. The passed-in `request` is mutated locally.
    ///
    /// Usage:
    /// ```swift
    /// // Given a `URLRequest` and an encoding strategy:
    /// // let body: Parameters = ["name": "Ana", "age": 28]
    /// // let query: Parameters = ["page": 1, "limit": 20]
    /// // try configureParameters(bodyParameters: body,
    /// //                         bodyEncoding: bodyEncoding,
    /// //                         urlParameters: query,
    /// //                         request: &request)
    /// ```
    ///
    /// See Also:
    /// - `ParameterEncoding.encode(urlRequest:bodyParameters:bodyArrayParameters:urlParameters:)`
    /// - `configureArrayParameters(bodyArrayParameters:bodyEncoding:urlParameters:request:)`
    fileprivate func configureParameters(bodyParameters: Parameters?,
                                         bodyEncoding: ParameterEncoding,
                                         urlParameters: Parameters?,
                                         request: inout URLRequest) throws {
        do {
            
            try bodyEncoding.encode(urlRequest: &request,
                                    bodyParameters: bodyParameters, urlParameters: urlParameters)
        } catch {
            throw error
        }
    }
    
    
    /// Encodes an array payload and/or URL query parameters into the provided `URLRequest` using the given encoding strategy.
    /// 
    /// Overview:
    /// - Use this helper when your request body is an array (e.g., `[[String: Any]]`) rather than a key–value dictionary.
    /// - Delegates serialization and header configuration to the supplied `ParameterEncoding`.
    /// - Mutates `request` in place to:
    ///   - Attach an HTTP body derived from `bodyArrayParameters` (format depends on `bodyEncoding`).
    ///   - Append `urlParameters` to the URL as a query string when provided.
    ///   - Set or update any headers required by the chosen encoding (e.g., `Content-Type`).
    ///
    /// Behavior:
    /// - If both `bodyArrayParameters` and `urlParameters` are `nil`, the function is effectively a no‑op.
    /// - The exact serialization (JSON array, URL‑encoded, multipart, etc.) and header behavior are defined by `bodyEncoding`.
    ///
    /// Parameters:
    /// - bodyArrayParameters: The array payload to encode into the HTTP body. Pass `nil` to omit a body.
    /// - bodyEncoding: The `ParameterEncoding` strategy responsible for serializing the body and/or query and setting any required headers.
    /// - urlParameters: A dictionary of query items to append to the request URL. Pass `nil` to omit query items.
    /// - request: The `URLRequest` to mutate with the encoded body, query, and any headers required by the encoding strategy.
    ///
    /// Throws:
    /// - Rethrows any error produced by `bodyEncoding.encode(...)`, such as serialization or validation failures.
    ///
    /// Side Effects:
    /// - Mutates `request` in place (HTTP body, URL, and/or headers).
    ///
    /// Thread Safety:
    /// - Pure helper with respect to global state; safe to call from any thread. The passed‑in `request` is mutated locally.
    ///
    /// Usage:
    /// ```swift
    /// var request = URLRequest(url: endpointURL)
    /// let arrayBody: ArrayParameters = [["id": 1, "name": "A"], ["id": 2, "name": "B"]]
    /// let query: Parameters = ["include": "meta"]
    /// try configureArrayParameters(bodyArrayParameters: arrayBody,
    ///                              bodyEncoding: JSONParameterEncoder.default,
    ///                              urlParameters: query,
    ///                              request: &request)
    /// ```
    ///
    /// See Also:
    /// - `ParameterEncoding.encode(urlRequest:bodyParameters:bodyArrayParameters:urlParameters:)`
    /// - `configureParameters(bodyParameters:bodyEncoding:urlParameters:request:)`
    fileprivate func configureArrayParameters(bodyArrayParameters: ArrayParameters?,
                                         bodyEncoding: ParameterEncoding,
                                         urlParameters: Parameters?,
                                         request: inout URLRequest) throws {
        do {
            
            try bodyEncoding.encode(
                urlRequest: &request,
                bodyParameters: nil,
                bodyArrayParameters: bodyArrayParameters,
                urlParameters: urlParameters
            )
        } catch {
            throw error
        }
    }
    

    
}
