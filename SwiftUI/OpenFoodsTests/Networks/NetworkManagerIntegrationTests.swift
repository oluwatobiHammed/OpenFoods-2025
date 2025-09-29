//
//  NetworkManagerIntegrationTests.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-28.
//

import XCTest
@testable import OpenFoods

// MARK: - Network Manager Integration Tests
class NetworkManagerIntegrationTests: XCTestCase {
    
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
    }
    
    func testFetchFoodsSuccess() async throws {
        let testFood = Food()
        testFood.id = 1
        testFood.name = "Pizza"
        testFood.isLiked = false
        testFood.photoURL = ""
        testFood.description = "Italian"
        testFood.countryOfOrigin =  "IT"
        testFood.lastUpdatedDate = ""
        
        let testFood1 = Food()
        testFood1.id = 2
        testFood1.name = "Sushi"
        testFood1.isLiked = false
        testFood1.photoURL = ""
        testFood1.description = "Japanese"
        testFood1.countryOfOrigin =  "JP"
        testFood1.lastUpdatedDate = ""
        
        let testFoods = Foods()
        testFoods.foods = [testFood,testFood1]
        testFoods.totalCount = 2
        mockNetworkManager.mockFoods = testFoods
        
        let result = try await mockNetworkManager.fetchFoods(page: 0)
        
        XCTAssertTrue(mockNetworkManager.fetchFoodsCalled)
        XCTAssertEqual(result.foods.count, 2)
        XCTAssertEqual(result.totalCount, 2)
        XCTAssertEqual(result.foods[0].name, "Pizza")
    }
    
    func testFetchFoodsError() async {
        mockNetworkManager.shouldThrowError = true
        
        do {
            _ = try await mockNetworkManager.fetchFoods(page: 0)
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(mockNetworkManager.fetchFoodsCalled)
            XCTAssertTrue(error.localizedDescription.contains("network connection"))
        }
    }
    
    func testLikeFoodSuccess() async throws {
        mockNetworkManager.mockLikeResult = true
        
        let result = try await mockNetworkManager.likeFood(id: 1)
        
        XCTAssertTrue(mockNetworkManager.likeFoodCalled)
        XCTAssertTrue(result)
    }
    
    func testUnlikeFoodSuccess() async throws {
        mockNetworkManager.mockLikeResult = true
        
        let result = try await mockNetworkManager.unlikeFood(id: 1)
        
        XCTAssertTrue(mockNetworkManager.unlikeFoodCalled)
        XCTAssertTrue(result)
    }
    
    func testLikeFoodError() async {
        mockNetworkManager.shouldThrowError = true
        
        do {
            _ = try await mockNetworkManager.likeFood(id: 1)
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(mockNetworkManager.likeFoodCalled)
        }
    }
}
