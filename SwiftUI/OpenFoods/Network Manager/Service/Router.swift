//
//  Router.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import Foundation


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

enum NetworkEnvironment {
    case RELEASE, PRODUCTION, DEVELOPMENT
    
    var env: String {
        switch self {
        case .RELEASE, .PRODUCTION: return "production"
            
        case .DEVELOPMENT: return "development"
        
        }
    }
}


enum Result<Error>{
    case success
    case failure(Error)
}

public typealias NetworkRouterCompletion = (_ data: Data?,_ response: URLResponse?,_ error: Error?)->()

protocol NetworkRouter: AnyObject {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint) async -> (Data?,URLResponse?, Error?)
}
struct ErrorMessages: Decodable, Error {
    let message: [String]?
    let email: [String]?
}
class Router<EndPoint: EndPointType>: NetworkRouter {

    private let session = URLSession(configuration: .default)
    private var task: URLSessionTask?
    
    private var isDebugModeEnabled: Bool = {
        guard let debugModeState = Bundle.main.object(forInfoDictionaryKey: "DebugModeState") as? NSString,
                debugModeState.boolValue else { return false }
        return debugModeState.boolValue
    }()
    
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
    
    
    func requestURL(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        task = session.dataTask(with: route.baseURL, completionHandler: { (data, response, error) in
            completion(data, response, error)
        })
        task?.resume()
    }
    
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
