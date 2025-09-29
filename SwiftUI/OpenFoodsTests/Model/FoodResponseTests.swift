//
//  FoodResponseTests.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-28.
//

import XCTest
@testable import OpenFoods

// MARK: - Food Response Tests
class FoodResponseTests: XCTestCase {
    
    func testFoodResponseDecoding() throws {
        let json = """
        {
            "foods": [
                {
                    "id": 99,
                    "name": "French Onion Soup",
                    "isLiked": false,
                    "photoURL": "https://example.com/images/soup.jpg",
                    "description": "A delicious French soup",
                    "countryOfOrigin": "FR",
                    "lastUpdatedDate": "1970-01-01T00:00:00Z"
                }
            ],
            "totalCount": 1
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try Foods.decode(data: data)
        
        XCTAssertEqual(response.foods.count, 1)
        XCTAssertEqual(response.totalCount, 1)
        XCTAssertEqual(response.foods.first?.name, "French Onion Soup")
    }
    
    func testEmptyFoodResponse() throws {
        let json = """
        {
            "foods": [],
            "totalCount": 0
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try Foods.decode(data: data)
        
        XCTAssertEqual(response.foods.count, 0)
        XCTAssertEqual(response.totalCount, 0)
    }
}
