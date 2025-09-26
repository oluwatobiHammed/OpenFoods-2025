//
//  URLParameterEncoding.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import Foundation

public struct URLParameterEncoder: ParameterEncoder {
    
    public func encode(urlRequest: inout URLRequest, withArrayParameters arrayParameters: ArrayParameters) throws {
        
    }
    
    /// Encodes a dictionary of URL parameters into the query component of a `URLRequest`.
    ///
    /// This method reads the existing `url` of the provided `URLRequest`, constructs
    /// `URLComponents`, and transforms each key/value pair in `parameters` into a
    /// `URLQueryItem`. The resulting query items are assigned back to the request's URL,
    /// effectively appending (or replacing) the query string.
    ///
    /// - Important:
    ///   - Existing query items on the request's URL are replaced. If you need to
    ///     preserve existing query items, merge them before calling this method.
    ///   - Values are converted to strings using `String(describing:)` (via string
    ///     interpolation). Ensure your `Parameters` values are representable as strings
    ///     in the way your API expects.
    ///   - This encoder only handles flat key/value pairs. For arrays or nested
    ///     structures, use a dedicated encoder (e.g., `encode(urlRequest:withArrayParameters:)`)
    ///     or pre-process your parameters accordingly.
    ///
    /// - Parameters:
    ///   - urlRequest: The request whose URL will be mutated to include the encoded
    ///                 query parameters. Passed as `inout`.
    ///   - parameters: A dictionary of key/value pairs to encode into the URL's query
    ///                 string.
    /// - Throws: `NetworkError.missingURL` if the `urlRequest` does not contain a URL.
    /// - Note: If `parameters` is empty or `URLComponents` cannot be constructed from
    ///         the request's URL, the request is left unchanged.
    /// - SeeAlso: `URLComponents`, `URLQueryItem`
    ///
    /// - Example:
    ///   ```swift
    ///   var request = URLRequest(url: URL(string: "https://api.example.com/search")!)
    ///   let params: Parameters = [
    ///       "q": "apple watch",
    ///       "page": 1,
    ///       "lang": "en"
    ///   ]
    ///   try URLParameterEncoder().encode(urlRequest: &request, withParameters: params)
    ///   // request.url might become:
    ///   // https://api.example.com/search?q=apple%20watch&page=1&lang=en
    ///   ```
    public func encode(urlRequest: inout URLRequest, withParameters parameters: Parameters) throws {
        
        guard let url = urlRequest.url else { throw NetworkError.missingURL }
        
        if var urlComponents = URLComponents(url: url,
                                             resolvingAgainstBaseURL: false), !parameters.isEmpty {
            
            urlComponents.queryItems = [URLQueryItem]()
            
            for (key,value) in parameters {
                let queryItem = URLQueryItem(name: key,
                                             value: "\(value)")
                urlComponents.queryItems?.append(queryItem)
            }
            urlRequest.url = urlComponents.url
        }
    }
}
