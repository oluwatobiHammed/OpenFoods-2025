//
//  ParameterEncoding.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//
import Foundation

public typealias Parameters = [String : Any]
public typealias ArrayParameters = T
public typealias T = Encodable

public protocol ParameterEncoder {
    func encode(urlRequest: inout URLRequest, withParameters parameters: Parameters) throws
    func encode(
        urlRequest: inout URLRequest,
        withArrayParameters arrayParameters: ArrayParameters
    ) throws
    
}


public enum ParameterEncoding {
    case urlEncoding
    case jsonEncoding
    case urlAndJsonEncoding
    case urlAndArrayJsonEncoding
    case bodyAndHeaderEncoding

    /**
     Encodes URL and/or HTTP body parameters into the provided URLRequest according to the selected `ParameterEncoding` strategy.
     
     This method centralizes parameter encoding for all supported strategies:
     - `urlEncoding`: Encodes `urlParameters` into the request URL (query string).
     - `jsonEncoding`: Encodes `urlParameters` into the URL and `bodyParameters` as a JSON body.
     - `urlAndJsonEncoding`: Same behavior as `jsonEncoding` (explicit combined URL + JSON body encoding).
     - `urlAndArrayJsonEncoding`: Encodes `urlParameters` into the URL and `bodyArrayParameters` (any `Encodable`, such as an array) as a JSON body.
     - `bodyAndHeaderEncoding`: Encodes `urlParameters` into the URL and `bodyParameters` as a JSON body; encoder(s) may also set appropriate HTTP headers (e.g., `Content-Type`).
     
     Notes:
     - `urlParameters == nil` is treated as an empty dictionary; no URL query items are added if there are none.
     - An empty `bodyParameters` dictionary is ignored (treated as `nil`) to avoid sending an empty JSON object.
     - Only one of `bodyParameters` or `bodyArrayParameters` is used depending on the selected case.
     - Underlying encoders (e.g., `URLParameterEncoder`, `JSONParameterEncoder`) may set headers such as `Content-Type` or `Accept` as needed.
     
     - Parameters:
     - urlRequest: The request to mutate. The method updates the URL’s query items and/or HTTP body in place.
     - bodyParameters: Key–value pairs to encode as a JSON body for cases that accept dictionary-based JSON bodies.
     - bodyArrayParameters: An `Encodable` payload (commonly an array) to encode as a JSON body for `.urlAndArrayJsonEncoding`.
     - urlParameters: Key–value pairs to encode as URL query parameters.
     
     - Throws: Rethrows any error from the underlying encoders, including but not limited to:
     - `NetworkError.missingURL` if the request’s URL is `nil` when URL encoding is required.
   - `NetworkError.encodingFailed` if parameter encoding fails.
   - Other errors thrown by the specific encoder implementations.

 - SeeAlso: `ParameterEncoding`, `ParameterEncoder`, `URLParameterEncoder`, `JSONParameterEncoder`
    */

    public func encode(urlRequest: inout URLRequest,
                       bodyParameters: Parameters?,
                       bodyArrayParameters: ArrayParameters? = nil,
                       urlParameters: Parameters?) throws {
        do {
            
            let params = urlParameters ?? [:]
            
            let clarifiedBodyParameters = bodyParameters?.isEmpty == false ? bodyParameters : nil
            
            switch self {
            case .urlEncoding:
                try URLParameterEncoder().encode(urlRequest: &urlRequest, withParameters: params)
                
            case .jsonEncoding, .urlAndJsonEncoding:
                try URLParameterEncoder().encode(urlRequest: &urlRequest, withParameters: params)
                if let bodyParameters = clarifiedBodyParameters {
                    try JSONParameterEncoder().encode(urlRequest: &urlRequest, withParameters: bodyParameters)
                }
                
            case .urlAndArrayJsonEncoding:
                try URLParameterEncoder().encode(urlRequest: &urlRequest, withParameters: params)
                if let bodyArrayParameters = bodyArrayParameters {
                    try JSONParameterEncoder().encode(urlRequest: &urlRequest, withArrayParameters: bodyArrayParameters)
                }
                
                
            case .bodyAndHeaderEncoding:
                try URLParameterEncoder().encode(urlRequest: &urlRequest, withParameters: params)
                if let bodyParameters = clarifiedBodyParameters {
                    try JSONParameterEncoder().encode(urlRequest: &urlRequest, withParameters: bodyParameters)
                }
                
            }
        } catch {
            throw error
        }
    }


}



/**
 A small, focused set of errors that can occur while preparing parameters for a `URLRequest`.
 
 `NetworkError` is thrown by parameter encoders (e.g., `URLParameterEncoder`, `JSONParameterEncoder`) and by
 the high–level `ParameterEncoding.encode(…)` helper when it detects situations that prevent a request from
 being constructed correctly.
 
 Case overview:
 - `parametersNil`: Emitted when required parameters were expected but found to be `nil`. For example, a request
 builder might pass `nil` where a non-optional dictionary was needed.
 - `encodingFailed`: Emitted when parameters cannot be converted into the desired format (e.g., JSON serialization
 fails or URL query items cannot be created from the provided values).
 - `missingURL`: Emitted when URL encoding is requested but the `URLRequest` does not contain a valid `URL`.
 
 Usage:
 - Inspect the thrown error and handle accordingly. For example, you might log `encodingFailed` with the parameters
 that caused the failure, prompt for a bug report in debug builds, or retry with corrected input.
 
 Example:
 ```swift
 do {
 try ParameterEncoding.urlAndJsonEncoding.encode(
 urlRequest: &request,
 bodyParameters: ["name": "Taylor"],
 urlParameters: ["page": 1]
 )
 } catch let error as NetworkError {
 switch error {
 case .parametersNil:
 // Provide fallback values or avoid making the request.
 break
 case .encodingFailed:
 // Log and investigate the payload that failed to encode.
 break
 case .missingURL:
 // Ensure the request has a valid URL before encoding.
 break
     }
 } catch {
     // Handle non-NetworkError failures (e.g., underlying encoder errors).
 }
 */

public enum NetworkError : String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
}

