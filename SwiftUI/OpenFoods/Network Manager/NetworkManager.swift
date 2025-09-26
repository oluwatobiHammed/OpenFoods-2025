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
    
    
    /// Fetches a paginated list of foods from the backend API.
    /// 
    /// This asynchronous method issues a GET request for the specified page and attempts to
    /// decode the response body into a `Foods` model. It uses `handleNetworkResponse(_:)` to
    /// interpret the HTTP status and will proceed to decode on success (including HTTP 404,
    /// which is treated as success in the current implementation).
    ///
    /// Side effects:
    /// - Logs the raw JSON response to the console.
    ///
    /// - Parameter page: The page index to fetch (typically 1-based, depending on the API).
    ///
    /// - Returns: A `Foods` value decoded from the server response.
    ///
    /// - Throws:
    ///   - `URLError.notConnectedToInternet` when there is no network connectivity.
    ///   - An `NSError` with `NetworkResponse.noData` when the response contains no data.
    ///   - An `NSError` with `NetworkResponse.unableToDecode` when decoding the response fails.
    ///   - Other HTTP-related `NSError`s produced by `handleNetworkResponse(_:)`, such as
    ///     `authenticationError`, `badRequest`, `outdated`, or `failed`, carrying the HTTP status code.
    ///
    /// - Important: This call is asynchronous and must be awaited.
    ///
    /// - SeeAlso: `NetworkManagerProtocol.fetchFoods(page:)`, `handleNetworkResponse(_:)`.
    ///
    /// - Example:
    /// ```swift
    /// let manager: NetworkManagerProtocol = NetworkManager()
    /// do {
    ///     let foods = try await manager.fetchFoods(page: 1)
    ///     // Use `foods`
    /// } catch {
    ///     // Handle error
    /// }
    /// ```
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
                     print(jsonData)
                    
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
    
    /// Sends a request to mark a food item as “liked” on the backend.
    /// 
    /// This asynchronous method delegates to `updateFoodLikeStatus(id:endpoint:)` with the
    /// `"like"` endpoint and returns whether the operation succeeded according to the server
    /// response.
    /// 
    /// - Parameter id: The unique identifier of the food item to like.
    /// 
    /// - Returns: `true` if the server indicates the like operation succeeded; otherwise `false`.
    /// 
    /// - Throws:
    ///   - `URLError.notConnectedToInternet` when there is no network connectivity.
    ///   - An `NSError` with `NetworkResponse.noData` when the response contains no data.
    ///   - An `NSError` with `NetworkResponse.unableToDecode` when response decoding fails.
    ///   - Other HTTP-related `NSError`s produced by `handleNetworkResponse(_:)`, such as
    ///     `authenticationError`, `badRequest`, `outdated`, or `failed`, carrying the HTTP status code.
    /// 
    /// - Important: This call is asynchronous and must be awaited.
    /// 
    /// - SeeAlso: `unlikeFood(id:)`, `updateFoodLikeStatus(id:endpoint:)`, `handleNetworkResponse(_:)`.
    /// 
    /// - Example:
    /// ```swift
    /// let manager: NetworkManagerProtocol = NetworkManager()
    /// do {
    ///     let didLike = try await manager.likeFood(id: 42)
    ///     if didLike {
    ///         // Update UI to reflect the liked state
    ///     }
    /// } catch {
    ///     // Present an error to the user
    /// }
    /// ```
    func likeFood(id: Int) async throws -> Bool {
        return try await updateFoodLikeStatus(id: id, endpoint: "like")
    }
    
    /// Sends a request to remove the “like” from a food item on the backend.
    /// 
    /// This asynchronous method delegates to `updateFoodLikeStatus(id:endpoint:)` with the
    /// `"unlike"` endpoint and returns whether the operation succeeded according to the server
    /// response.
    /// 
    /// - Parameter id: The unique identifier of the food item to unlike.
    /// 
    /// - Returns: `true` if the server indicates the unlike operation succeeded; otherwise `false`.
    /// 
    /// - Throws:
    ///   - `URLError.notConnectedToInternet` when there is no network connectivity.
    ///   - An `NSError` with `NetworkResponse.noData` when the response contains no data.
    ///   - An `NSError` with `NetworkResponse.unableToDecode` when response decoding fails.
    ///   - Other HTTP-related `NSError`s produced by `handleNetworkResponse(_:)`, such as
    ///     `authenticationError`, `badRequest`, `outdated`, or `failed`, carrying the HTTP status code.
    /// 
    /// - Important: This call is asynchronous and must be awaited.
    /// 
    /// - SeeAlso: `likeFood(id:)`, `updateFoodLikeStatus(id:endpoint:)`, `handleNetworkResponse(_:)`.
    /// 
    /// - Example:
    /// ```swift
    /// let manager: NetworkManagerProtocol = NetworkManager()
    /// do {
    ///     let didUnlike = try await manager.unlikeFood(id: 42)
    ///     if didUnlike {
    ///         // Update UI to reflect the unliked state
    ///     }
    /// } catch {
    ///     // Present an error to the user
    /// }
    /// ```
    func unlikeFood(id: Int) async throws -> Bool {
         return try await updateFoodLikeStatus(id: id, endpoint: "unlike")
     }
    
    /// Updates the “like” status of a food item on the backend.
    ///
    /// This private helper issues a request to the server to either like or unlike a food item,
    /// depending on the provided `endpoint` value (typically "like" or "unlike"). It evaluates the
    /// HTTP response using `handleNetworkResponse(_:)`, attempts to decode the body into a
    /// `LikeResponse`, and returns the `success` flag reported by the server.
    ///
    /// Side effects:
    /// - Logs the raw JSON response to the console for debugging purposes.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the food item whose like status is being updated.
    ///   - endpoint: The API action path segment indicating the operation to perform, usually
    ///               "like" to add a like or "unlike" to remove it.
    ///
    /// - Returns: `true` if the server indicates the operation succeeded; otherwise `false`.
    ///
    /// - Throws:
    ///   - `URLError.notConnectedToInternet` when there is no network connectivity.
    ///   - An `NSError` with `NetworkResponse.noData` when the response contains no data.
    ///   - An `NSError` with `NetworkResponse.unableToDecode` when decoding the response fails.
    ///   - Other HTTP-related `NSError`s produced by `handleNetworkResponse(_:)`, such as
    ///     `authenticationError`, `badRequest`, `outdated`, or `failed`, carrying the HTTP status code.
    ///
    /// - Important: This call is asynchronous and must be awaited.
    ///
    /// - SeeAlso: `likeFood(id:)`, `unlikeFood(id:)`, `handleNetworkResponse(_:)`, `LikeResponse`.
    ///
    /// - Example:
    /// ```swift
    /// // Internally used by `likeFood(id:)` / `unlikeFood(id:)`:
    /// let didSucceed = try await updateFoodLikeStatus(id: 42, endpoint: "like")
    /// ```
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
                    
                     print(jsonData)
                    
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
