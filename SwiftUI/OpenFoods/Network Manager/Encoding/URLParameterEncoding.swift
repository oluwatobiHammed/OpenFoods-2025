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
