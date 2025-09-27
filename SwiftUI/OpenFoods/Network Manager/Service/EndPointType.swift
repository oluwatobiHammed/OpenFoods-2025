//
//  EndPointType.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import Foundation

/**
 A type that describes a single HTTP endpoint in your networking layer.
 
 Conform to `EndPointType` to encapsulate everything needed to build a `URLRequest`
 for a specific resource, including:
 - The service's base URL
 - The resource path relative to the base URL
 - The HTTP method (verb)
 - The request "task" (e.g., query/body parameters, encoding strategy, and headers)
 
 Typical usage is to model an API surface as an `enum` with a case per endpoint that
 conforms to this protocol.
 
 Example:
 ```swift
 enum UserAPI: EndPointType {
 case profile(id: String)
 case search(query: String, page: Int)
 
 var baseURL: URL { URL(string: "https://api.example.com")! }
 
 var path: String {
 switch self {
 case .profile(let id): return "users/\(id)"
 case .search: return "users/search"
 }
 }
 
 var httpMethod: HTTPMethod {
 switch self {
 case .profile: return .get
 case .search: return .get
 }
 }
 
 var task: HTTPTask {
 switch self {
 case .profile:
             return .requestPlain
         case .search(let query, let page):
             return .requestParameters(parameters: ["q": query, "page": page],
                                      encoding: .urlQuery)
         }
     }
 }
 */

protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
}
