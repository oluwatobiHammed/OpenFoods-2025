//
//  OpenFoodsIntegrationTests.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-28.
//


import XCTest
@testable import OpenFoods

// MARK: - Integration Tests
class OpenFoodsIntegrationTests: XCTestCase {
    
    func testLocalizationManagerIntegration() {
        let manager = LocalizationManager.shared
        let originalLanguage = manager.currentLanguage
        
        // Test language switching
        manager.setLanguage("fr")
        XCTAssertEqual("settings".localized, "Paramètres")
        
        manager.setLanguage("de")
        XCTAssertEqual("settings".localized, "Einstellungen")
        
        // Reset
        manager.setLanguage(originalLanguage)
    }
    
    func testLocalStorageAndViewModel() {
        let mockNetwork = MockNetworkManager()
        let viewModel = FoodListViewModel(networkManager: mockNetwork)
        let storage = LocalStorageManager.shared
        
        // Clear any existing data
        storage.clearAllData()
        
        // Test initial state
        let (initialSync, initialPending) = viewModel.getCacheInfo()
        XCTAssertNil(initialSync)
        XCTAssertEqual(initialPending, 0)
        let food = Food()
        food.id = 1
        food.name =  "Pizza"
        food.isLiked = false
        food.photoURL = ""
        food.description = ""
        food.countryOfOrigin = "IT"
        food.lastUpdatedDate = ""
        
        // Add some test data
        let testFoods = [food]
        
        storage.saveFoods(testFoods)
        storage.savePendingLike(foodId: 1, isLiked: true)
        
        // Test cache info
        let (newSync, newPending) = viewModel.getCacheInfo()
        XCTAssertNotNil(newSync)
        XCTAssertEqual(newPending, 1)
        
        // Test clear cache
        viewModel.clearCache()
        let (clearedSync, clearedPending) = viewModel.getCacheInfo()
        XCTAssertNil(clearedSync)
        XCTAssertEqual(clearedPending, 0)
    }
    
    func testLocalizationAndViewModelIntegration() {
           let mockNetwork = MockNetworkManager()
           let manager = LocalizationManager.shared
           let viewModel = FoodListViewModel(networkManager: mockNetwork)
           let originalLanguage = manager.currentLanguage
           
           // Test language switching with view model
           manager.setLanguage("fr")
           XCTAssertEqual("offline_mode".localized, "Mode hors ligne")
           
           manager.setLanguage("de")
           XCTAssertEqual("offline_mode".localized, "Offline-Modus")
           
           // Reset
           manager.setLanguage(originalLanguage)
           
           // View model should work regardless of language
           XCTAssertEqual(viewModel.foods.count, 0)
       }
    
    func testLocalStorageAndViewModelIntegration() {
          let mockNetwork = MockNetworkManager()
          let viewModel = FoodListViewModel(networkManager: mockNetwork)
          let storage = LocalStorageManager.shared
          
          storage.clearAllData()
          
          let (initialSync, initialPending) = viewModel.getCacheInfo()
          XCTAssertNil(initialSync)
          XCTAssertEqual(initialPending, 0)
        let food = Food()
        food.id = 1
        food.name =  "Pizza"
        food.isLiked = false
        food.photoURL = ""
        food.description = ""
        food.countryOfOrigin = "IT"
        food.lastUpdatedDate = ""
          let testFoods = [food]
          
          storage.saveFoods(testFoods)
          storage.savePendingLike(foodId: 1, isLiked: true)
          
          let (newSync, newPending) = viewModel.getCacheInfo()
          XCTAssertNotNil(newSync)
          XCTAssertEqual(newPending, 1)
          
          viewModel.clearCache()
          let (clearedSync, clearedPending) = viewModel.getCacheInfo()
          XCTAssertNil(clearedSync)
          XCTAssertEqual(clearedPending, 0)
      }
    
    func testNetworkAndStorageIntegration() async throws {
        let mockNetwork = MockNetworkManager()
        let storage = LocalStorageManager.shared
        
        storage.clearAllData()
        let food = Food()
        food.id = 1
        food.name =  "Burger"
        food.isLiked = true
        food.photoURL = ""
        food.description = ""
        food.countryOfOrigin = "US"
        food.lastUpdatedDate = ""
        
        let food1 = Food()
        food1.id = 1
        food1.name =  "Ramen"
        food1.isLiked = false
        food1.photoURL = ""
        food1.description = ""
        food1.countryOfOrigin = "JP"
        food1.lastUpdatedDate = ""
        let testFoods = Foods()
        testFoods.foods = [food,food1]
        testFoods.totalCount = 2
        
        mockNetwork.mockFoods = testFoods
        
        let fetchedFoods = try await mockNetwork.fetchFoods(page: 0)
        
        storage.saveFoods(fetchedFoods.foods)
        
        let cachedFoods = storage.loadFoods()
        XCTAssertEqual(cachedFoods.count, 2)
        XCTAssertEqual(cachedFoods[0].name, "Burger")
        XCTAssertEqual(cachedFoods[1].name, "Ramen")
        
        storage.clearAllData()
    }
    
    func testFullOfflineFlow() async throws {
          let mockNetwork = MockNetworkManager()
          let storage = LocalStorageManager.shared
          
          storage.clearAllData()
        let food = Food()
        food.id = 1
        food.name =  "Pasta"
        food.isLiked = false
        food.photoURL = ""
        food.description = "Italian pasta"
        food.countryOfOrigin = "IT"
        food.lastUpdatedDate = "2024-01-01T00:00:00Z"
          // Step 1: Fetch data while online
          let onlineFoods = Foods()
          onlineFoods.foods = [food]
          onlineFoods.totalCount = 1
          mockNetwork.mockFoods = onlineFoods
          let fetchedFoods = try await mockNetwork.fetchFoods(page: 0)
          
          // Step 2: Save to local storage
          storage.saveFoods(fetchedFoods.foods)
          
          // Step 3: Simulate offline - like a food
          storage.savePendingLike(foodId: 1, isLiked: true)
          
          // Step 4: Verify pending like is saved
          let pendingLikes = storage.getPendingLikes()
          XCTAssertEqual(pendingLikes.count, 1)
          XCTAssertEqual(pendingLikes["1"], true)
          
          // Step 5: Simulate coming back online - sync pending likes
          mockNetwork.mockLikeResult = true
          let likeSuccess = try await mockNetwork.likeFood(id: 1)
          XCTAssertTrue(likeSuccess)
          
          // Step 6: Clear pending like after successful sync
          if likeSuccess {
              storage.clearPendingLike(foodId: 1)
          }
          
          // Step 7: Verify pending likes are cleared
          let updatedPendingLikes = storage.getPendingLikes()
          XCTAssertEqual(updatedPendingLikes.count, 0)
          
          storage.clearAllData()
      }
    
}
