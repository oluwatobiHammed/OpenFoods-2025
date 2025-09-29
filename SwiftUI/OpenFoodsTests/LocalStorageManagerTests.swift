//
//  LocalStorageManagerTests.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-28.
//

import XCTest
@testable import OpenFoods

// MARK: - Local Storage Manager Tests
class LocalStorageManagerTests: XCTestCase {
    
    var localStorageManager: LocalStorageManager!
    
    override func setUp() {
        super.setUp()
        localStorageManager = LocalStorageManager.shared
        // Clear any existing data
        localStorageManager.clearAllData()
    }
    
    override func tearDown() {
        localStorageManager.clearAllData()
        super.tearDown()
    }
    
    func testSaveAndLoadFoods() {
        let food1 = Food()
        food1.id = 1
        food1.name = "Pizza"
        food1.isLiked = true
        food1.photoURL = ""
        food1.description = "Delicious"
        food1.countryOfOrigin =  "IT"
        food1.lastUpdatedDate = ""
        
        let food2 = Food()
        food2.id = 1
        food2.name = "Sushi"
        food2.isLiked = false
        food2.photoURL = ""
        food2.description = "Fresh"
        food2.countryOfOrigin =  "JP"
        food2.lastUpdatedDate = ""
        
        let testFoods = [food1, food2]
        
        localStorageManager.saveFoods(testFoods)
        let loadedFoods = localStorageManager.loadFoods()
        
        XCTAssertEqual(loadedFoods.count, 2)
        XCTAssertEqual(loadedFoods[0].name, "Pizza")
        XCTAssertTrue(loadedFoods[0].isLiked)
        XCTAssertEqual(loadedFoods[1].name, "Sushi")
        XCTAssertFalse(loadedFoods[1].isLiked)
    }
    
    func testLoadEmptyFoods() {
        let foods = localStorageManager.loadFoods()
        XCTAssertEqual(foods.count, 0)
    }
    
    func testLastSyncDate() {
        XCTAssertNil(localStorageManager.getLastSyncDate())
        let food = Food()
        food.id = 1
        food.name = "Test"
        food.isLiked = false
        food.photoURL = ""
        food.description = ""
        food.countryOfOrigin =  "US"
        food.lastUpdatedDate = ""
        let testFoods = [food]
        localStorageManager.saveFoods(testFoods)
        
        let syncDate = localStorageManager.getLastSyncDate()
        XCTAssertNotNil(syncDate)
        XCTAssertTrue(abs(syncDate!.timeIntervalSinceNow) < 5) // Within 5 seconds
    }
    
    func testPendingLikes() {
         XCTAssertEqual(localStorageManager.getPendingLikes().count, 0)
         
         localStorageManager.savePendingLike(foodId: 1, isLiked: true)
         localStorageManager.savePendingLike(foodId: 2, isLiked: false)
         localStorageManager.savePendingLike(foodId: 3, isLiked: true)
         
         let pendingLikes = localStorageManager.getPendingLikes()
         XCTAssertEqual(pendingLikes.count, 3)
         XCTAssertEqual(pendingLikes["1"], true)
         XCTAssertEqual(pendingLikes["2"], false)
         XCTAssertEqual(pendingLikes["3"], true)
         
         localStorageManager.clearPendingLike(foodId: 1)
         let updatedLikes = localStorageManager.getPendingLikes()
         XCTAssertEqual(updatedLikes.count, 2)
         XCTAssertNil(updatedLikes["1"])
         XCTAssertEqual(updatedLikes["2"], false)
         XCTAssertEqual(updatedLikes["3"], true)
     }
    
    func testClearAllData() {
        let food = Food()
        food.id = 1
        food.name = "Test"
        food.isLiked = false
        food.photoURL = ""
        food.description = ""
        food.countryOfOrigin =  "US"
        food.lastUpdatedDate = ""
        let testFoods = [food]
        localStorageManager.saveFoods(testFoods)
        localStorageManager.savePendingLike(foodId: 1, isLiked: true)
        
        XCTAssertEqual(localStorageManager.loadFoods().count, 1)
        XCTAssertEqual(localStorageManager.getPendingLikes().count, 1)
        
        localStorageManager.clearAllData()
        
        XCTAssertEqual(localStorageManager.loadFoods().count, 0)
        XCTAssertEqual(localStorageManager.getPendingLikes().count, 0)
        XCTAssertNil(localStorageManager.getLastSyncDate())
    }
    
    func testSaveOverwritesPreviousData() {
        let firstFood = Food()
        firstFood.id = 1
        firstFood.name = "Pizza"
        firstFood.isLiked = true
        firstFood.photoURL = ""
        firstFood.description = ""
        firstFood.countryOfOrigin =  "IT"
        firstFood.lastUpdatedDate = ""
        let firstFoods = [firstFood]
        localStorageManager.saveFoods(firstFoods)
        
        XCTAssertEqual(localStorageManager.loadFoods().count, 1)
        let food1 = Food()
        food1.id = 1
        food1.name = "Sushi"
        food1.isLiked = false
        food1.photoURL = ""
        food1.description = ""
        food1.countryOfOrigin =  "JP"
        food1.lastUpdatedDate = ""
        
        let food2 = Food()
        food2.id = 1
        food2.name = "Tacos"
        food2.isLiked = true
        food2.photoURL = ""
        food2.description = ""
        food2.countryOfOrigin =  "MX"
        food2.lastUpdatedDate = ""
        let secondFoods = [food1,food2]
        localStorageManager.saveFoods(secondFoods)
        
        let loadedFoods = localStorageManager.loadFoods()
        XCTAssertEqual(loadedFoods.count, 2)
        XCTAssertEqual(loadedFoods[0].name, "Sushi")
        XCTAssertEqual(loadedFoods[1].name, "Tacos")
    }
    
    func testPendingLikeOverwrite() {
        localStorageManager.savePendingLike(foodId: 1, isLiked: true)
        XCTAssertEqual(localStorageManager.getPendingLikes()["1"], true)
        
        localStorageManager.savePendingLike(foodId: 1, isLiked: false)
        XCTAssertEqual(localStorageManager.getPendingLikes()["1"], false)
    }
}
