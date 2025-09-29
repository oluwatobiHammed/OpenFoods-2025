//
//  LikeResponseTests.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-28.
//

import XCTest
@testable import OpenFoods

// MARK: - LikeResponse Tests
class LikeResponseTests: XCTestCase {
    
    func testLikeResponseDecoding() throws {
        let json = """
        {
            "success": true
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try LikeResponse.decode(data: data)
        
        XCTAssertTrue(response.success)
    }
    
    func testLikeResponseFailure() throws {
        let json = """
        {
            "success": false
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try LikeResponse.decode(data: data)
        
        XCTAssertFalse(response.success)
    }
}
