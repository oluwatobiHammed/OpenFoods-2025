//
//  NetworkManager.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import Foundation

// MARK: - NetworkManager Protocol (for testability)
protocol NetworkManagerProtocol {
    func fetchFoods(page: Int) async throws -> Foods
    func likeFood(id: Int) async throws -> Bool
    func unlikeFood(id: Int) async throws -> Bool
}

// MARK: - NetworkManager
struct NetworkManager: NetworkManagerProtocol {
    
    let router = Router<Endpoints>()
    var isDebugModeEnabled: Bool {
        get {
            guard let debugModeState = Bundle.main.object(
                forInfoDictionaryKey:
                    "DebugModeState"
            ) as? NSString, debugModeState.boolValue else {
                return false
            }
            return debugModeState.boolValue
        }
    }
    
    
    func fetchFoods(page: Int) async throws -> Foods {
        let (data, response, error) = await router.request(.getFoods(page: page))
        
        if error != nil {
            throw  NSError(
                domain: "",
                code: URLError.Code.notConnectedToInternet.rawValue,
                userInfo: [NSLocalizedDescriptionKey : "Please check your network connection."]
            )
        }
        
        if let response = response as? HTTPURLResponse {
            let result = handleNetworkResponse(response)
            switch result {
            case .success:
                guard let responseData = data else {
                    throw NSError(
                        domain: "",
                        code: response.statusCode,
                        userInfo: [NSLocalizedDescriptionKey : NetworkResponse.noData.rawValue]
                    )
                }
                do {
                    
                    let jsonData = try JSONSerialization.jsonObject(
                        with: responseData,
                        options: .mutableContainers
                    )
                    if isDebugModeEnabled { print(jsonData) }
                    
                    guard let foods = try? Foods.decode(data: responseData) else {
                        throw NSError(
                            domain: "",
                            code: response.statusCode,
                            userInfo: [NSLocalizedDescriptionKey : NetworkResponse.unableToDecode.rawValue]
                        )
                    }
                  
                    return foods
                }catch {
                    
                    
                    throw NSError(
                        domain: "",
                        code: response.statusCode,
                        userInfo: [NSLocalizedDescriptionKey : NetworkResponse.unableToDecode.rawValue]
                    )
                }
            case .failure(let networkFailureError):
                throw networkFailureError
            }
        } else {
            throw NSError(
                domain: "",
                code: URLError.Code.notConnectedToInternet.rawValue,
                userInfo: [NSLocalizedDescriptionKey : "Please check your network connection."]
            )
        }
        
    }
    
    func likeFood(id: Int) async throws -> Bool {
        return try await updateFoodLikeStatus(id: id, endpoint: "like")
    }
    
    func unlikeFood(id: Int) async throws -> Bool {
         return try await updateFoodLikeStatus(id: id, endpoint: "unlike")
     }
    
    private func updateFoodLikeStatus(id: Int, endpoint: String) async throws -> Bool {
        let (data, response, error) = await router.request(.updateFoodLikeStatus(id: id, endpoint: endpoint))
        
        if error != nil {
            throw  NSError(
                domain: "",
                code: URLError.Code.notConnectedToInternet.rawValue,
                userInfo: [NSLocalizedDescriptionKey : "Please check your network connection."]
            )
        }
        
        if let response = response as? HTTPURLResponse {
            let result = handleNetworkResponse(response)
            switch result {
            case .success:
                guard let responseData = data else {
                    throw NSError(
                        domain: "",
                        code: response.statusCode,
                        userInfo: [NSLocalizedDescriptionKey : NetworkResponse.noData.rawValue]
                    )
                }
                do {
                    
                    let jsonData = try JSONSerialization.jsonObject(
                        with: responseData,
                        options: .mutableContainers
                    )
                    if isDebugModeEnabled { print(jsonData) }
                    
                    guard let like = try? LikeResponse.decode(data: responseData) else {
                        throw NSError(
                            domain: "",
                            code: response.statusCode,
                            userInfo: [NSLocalizedDescriptionKey : NetworkResponse.unableToDecode.rawValue]
                        )
                    }
                  
                    return like.success
                }catch {
                    
                    
                    throw NSError(
                        domain: "",
                        code: response.statusCode,
                        userInfo: [NSLocalizedDescriptionKey : NetworkResponse.unableToDecode.rawValue]
                    )
                }
            case .failure(let networkFailureError):
                throw networkFailureError
            }
        } else {
            throw NSError(
                domain: "",
                code: URLError.Code.notConnectedToInternet.rawValue,
                userInfo: [NSLocalizedDescriptionKey : "Please check your network connection."]
            )
        }
    }
}


func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<Error>{
   switch response.statusCode {
   case 200...299: return .success
   case 404: return .success
   case 401...500: return .failure(
    NSError(
        domain: "",
        code: response.statusCode,
        userInfo: [NSLocalizedDescriptionKey : NetworkResponse.authenticationError.rawValue]
    )
   )
   case 501...599: return .failure(
    NSError(
        domain: "",
        code: response.statusCode,
        userInfo: [NSLocalizedDescriptionKey : NetworkResponse.badRequest.rawValue]
    )
   )
   case 600: return .failure(
    NSError(
        domain: "",
        code: response.statusCode,
        userInfo: [NSLocalizedDescriptionKey : NetworkResponse.outdated.rawValue]
    )
   )
   default: return .failure(
    NSError(
        domain: "",
        code: response.statusCode,
        userInfo: [NSLocalizedDescriptionKey : NetworkResponse.failed.rawValue]
    )
   )
   }
}
