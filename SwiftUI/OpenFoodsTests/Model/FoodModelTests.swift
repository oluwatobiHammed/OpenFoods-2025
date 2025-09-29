//
//  FoodModelTests.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-28.
//


import XCTest
@testable import OpenFoods

// MARK: - Unit Tests

// MARK: - Food Model Tests
class FoodModelTests: XCTestCase {
    
    func testFoodDecoding() throws {
        let json = """
        {
            "id": 99,
            "name": "French Onion Soup",
            "isLiked": false,
            "photoURL": "https://example.com/images/soup.jpg",
            "description": "A delicious French soup",
            "countryOfOrigin": "FR",
            "lastUpdatedDate": "1970-01-01T00:00:00Z"
        }
        """
        
        let data = json.data(using: .utf8)!
        let food = try Food.decode(data: data)
        
        XCTAssertEqual(food.id, 99)
        XCTAssertEqual(food.name, "French Onion Soup")
        XCTAssertFalse(food.isLiked)
        XCTAssertEqual(food.photoURL, "https://example.com/images/soup.jpg")
        XCTAssertEqual(food.description, "A delicious French soup")
        XCTAssertEqual(food.countryOfOrigin, "FR")
        XCTAssertEqual(food.lastUpdatedDate, "1970-01-01T00:00:00Z")
    }
    
    func testFlagEmoji() {
        let frenchFood = Food()
        
        frenchFood.id = 2
        frenchFood.name =  "French Bread"
        frenchFood.isLiked = false
        frenchFood.photoURL = ""
        frenchFood.description = ""
        frenchFood.countryOfOrigin = "FR"
        frenchFood.lastUpdatedDate = ""
        
        XCTAssertEqual(frenchFood.flagEmoji, "🇫🇷")
        
        let usFood = Food()
        usFood.id = 2
        usFood.name =  "Hamburger"
        usFood.isLiked = false
        usFood.photoURL = ""
        usFood.description = ""
        usFood.countryOfOrigin = "US"
        usFood.lastUpdatedDate = ""
        
        XCTAssertEqual(usFood.flagEmoji, "🇺🇸")
    }
    
    func testFormattedDate() {
        let food = Food()
        food.id = 1
        food.name =  "Test Food"
        food.isLiked = false
        food.photoURL = ""
        food.description = ""
        food.countryOfOrigin = "US"
        food.lastUpdatedDate = "2023-12-25T10:30:00Z"
        // The formatted date should not be empty
        XCTAssertFalse(food.formattedDate.isEmpty)
        
        // Test invalid date format
        let invalidFood = Food()
        invalidFood.id = 2
        invalidFood.name =  "Test Food 2"
        invalidFood.isLiked = false
        invalidFood.photoURL = ""
        invalidFood.description = ""
        invalidFood.countryOfOrigin = "US"
        invalidFood.lastUpdatedDate = "invalid-date"
        XCTAssertEqual(invalidFood.formattedDate, "invalid-date")
    }
    
    func testFoodIdentifiable() {
        
        let food1 = Food()
        food1.id = 1
        food1.name =  "Pizza"
        food1.isLiked = false
        food1.photoURL = ""
        food1.description = ""
        food1.countryOfOrigin = "IT"
        food1.lastUpdatedDate = ""
   
        
        let food2 = Food()
        food2.id = 2
        food2.name =  "Sushi"
        food2.isLiked = false
        food2.photoURL = ""
        food2.description = ""
        food2.countryOfOrigin = "JP"
        food2.lastUpdatedDate = ""
    
        
        XCTAssertEqual(food1.id, 1)
        XCTAssertEqual(food2.id, 2)
        XCTAssertNotEqual(food1.id, food2.id)
    }
    
    func testFoodCodable() throws {
        
        let originalFood = Food()
        originalFood.id = 100
        originalFood.name =  "Paella"
        originalFood.isLiked = true
        originalFood.photoURL = "https://example.com/paella.jpg"
        originalFood.description = "Spanish rice dish"
        originalFood.countryOfOrigin = "ES"
        originalFood.lastUpdatedDate = "2024-01-01T12:00:00Z"
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalFood)
        
        // Decode
        let decodedFood = try Food.decode(data: data)
        
        XCTAssertEqual(originalFood.id, decodedFood.id)
        XCTAssertEqual(originalFood.name, decodedFood.name)
        XCTAssertEqual(originalFood.isLiked, decodedFood.isLiked)
        XCTAssertEqual(originalFood.countryOfOrigin, decodedFood.countryOfOrigin)
    }
}
