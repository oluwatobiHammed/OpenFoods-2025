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


private func getTimeZone() -> String {
    let seconds = TimeZone.current.secondsFromGMT()
    let hours = seconds/3600
    let minutes = abs(seconds/60) % 60
    return String(format: "%+.2d:%.2d", hours, minutes)
}

private func getClientVersion() -> String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
}


public enum NetworkError : String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
}

