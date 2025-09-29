//
//  MockNetworkManager.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-28.
//

@testable import OpenFoods
import Foundation
// MARK: - Mock Network Manager for Testing
class MockNetworkManager: NetworkManagerProtocol {
    var shouldThrowError = false
    var mockFoods: Foods?
    var mockLikeResult = true
    var fetchFoodsCalled = false
    var likeFoodCalled = false
    var unlikeFoodCalled = false
    
    func fetchFoods(page: Int) async throws -> Foods {
        fetchFoodsCalled = true
        
        if shouldThrowError {
            throw NSError(
                domain: "",
                code: URLError.Code.notConnectedToInternet.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "Please check your network connection."]
            )
        }
        let foods = Foods()
        foods.foods = []
        foods.totalCount = 0
        return mockFoods ?? foods
    }
    
    func likeFood(id: Int) async throws -> Bool {
        likeFoodCalled = true
        
        if shouldThrowError {
            throw NSError(
                domain: "",
                code: URLError.Code.notConnectedToInternet.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "Please check your network connection."]
            )
        }
        
        return mockLikeResult
    }
    
    func unlikeFood(id: Int) async throws -> Bool {
        unlikeFoodCalled = true
        
        if shouldThrowError {
            throw NSError(
                domain: "",
                code: URLError.Code.notConnectedToInternet.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "Please check your network connection."]
            )
        }
        
        return mockLikeResult
    }
}
