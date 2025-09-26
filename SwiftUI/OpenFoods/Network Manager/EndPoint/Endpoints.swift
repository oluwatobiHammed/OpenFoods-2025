//
//  B2BEndpoints.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import Foundation

enum Endpoints:EndPointType {
    case getFoods(page: Int)
    case updateFoodLikeStatus(id: Int, endpoint: String)
    
    var baseURL: URL {
     
        guard let url = URL(string: kAPI.Base_URL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .getFoods(let page):
            return kAPI.Endpoints.foods + "\(page)"
        case .updateFoodLikeStatus(let id, let endpoint):
            return kAPI.Endpoints.foods + "\(id)/" + "\(endpoint)"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .updateFoodLikeStatus(_, _):
            return .put
        default:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
            
        case .getFoods:
            return .requestHeaders(bodyEncoding: .urlEncoding)
            
        case .updateFoodLikeStatus(id: _, endpoint: _):
            return .requestHeaders(bodyEncoding: .urlEncoding)
        }
        
    }
}
