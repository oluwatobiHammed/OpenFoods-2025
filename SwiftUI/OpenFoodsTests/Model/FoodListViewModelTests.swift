//
//  FoodListViewModelTests.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-28.
//

import XCTest
@testable import OpenFoods
import Combine

// MARK: - Food List View Model Tests
class FoodListViewModelTests: XCTestCase {
    
    var viewModel: FoodListViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        viewModel = FoodListViewModel()
        
        cancellables = Set<AnyCancellable>()
        
        // Clear any cached data
        LocalStorageManager.shared.clearAllData()
    }
    
    override func tearDown() {
        LocalStorageManager.shared.clearAllData()
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Clear any cached data
        XCTAssertEqual(viewModel.foods.count, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isLoadingMore)
        XCTAssertFalse(viewModel.hasError)
        XCTAssertTrue(viewModel.errorMessage.isEmpty)
        XCTAssertFalse(viewModel.isOfflineMode)
        
    }
    

    
    func testClearCache() {
        // Add some test data
        let food = Food()
        food.id = 1
        food.name = "Test"
        food.isLiked = false
        food.photoURL = ""
        food.description = ""
        food.countryOfOrigin =  "US"
        food.lastUpdatedDate = ""
        let testFoods = [food]
        
        viewModel.foods = testFoods
        
        viewModel.clearCache()
        
        XCTAssertEqual(viewModel.foods.count, 0)
        
    }
    
   func testGetCacheInfo() {
       
           let (lastSync, pendingCount) = viewModel.getCacheInfo()
           XCTAssertNil(lastSync)
           XCTAssertEqual(pendingCount, 0)
           let food = Food()
           food.id = 1
           food.name = "Test"
           food.isLiked = false
           food.photoURL = ""
           food.description = ""
           food.countryOfOrigin =  "US"
           food.lastUpdatedDate = ""
           // Add some test data
           let testFoods = [food]
           LocalStorageManager.shared.saveFoods(testFoods)
           LocalStorageManager.shared.savePendingLike(foodId: 1, isLiked: true)
           
           let (newLastSync, newPendingCount) = viewModel.getCacheInfo()
           XCTAssertNotNil(newLastSync)
           XCTAssertEqual(newPendingCount, 1)
       
    }
    
    func testFoodsPublishedChanges() {
           let expectation = XCTestExpectation(description: "Foods changed")
           
           viewModel.$foods
               .dropFirst()
               .sink { foods in
                   XCTAssertEqual(foods.count, 1)
                   XCTAssertEqual(foods.first?.name, "Test Food")
                   expectation.fulfill()
               }
               .store(in: &cancellables)
        let testFood = Food()
        testFood.id = 1
        testFood.name = "Test Food"
        testFood.isLiked = false
        testFood.photoURL = ""
        testFood.description = ""
        testFood.countryOfOrigin =  "US"
        testFood.lastUpdatedDate = ""
       
           viewModel.foods = [testFood]
           
           wait(for: [expectation], timeout: 1.0)
       }
       
       func testLoadingStateChanges() {
           let expectation = XCTestExpectation(description: "Loading state changed")
           
           viewModel.$isLoading
               .dropFirst()
               .sink { isLoading in
                   XCTAssertTrue(isLoading)
                   expectation.fulfill()
               }
               .store(in: &cancellables)
           
           viewModel.isLoading = true
           
           wait(for: [expectation], timeout: 1.0)
       }
       
       func testErrorStateChanges() {
           let expectation = XCTestExpectation(description: "Error state changed")
           
           viewModel.$hasError
               .dropFirst()
               .sink { hasError in
                   XCTAssertTrue(hasError)
                   expectation.fulfill()
               }
               .store(in: &cancellables)
           
           viewModel.hasError = true
           viewModel.errorMessage = "Test error"
           
           wait(for: [expectation], timeout: 1.0)
       }
}
