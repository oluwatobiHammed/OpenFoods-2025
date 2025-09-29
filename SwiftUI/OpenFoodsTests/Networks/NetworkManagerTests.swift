//
//  NetworkManagerTests.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-28.
//

import XCTest
@testable import OpenFoods

// MARK: - Network Manager Tests
class NetworkManagerTests: XCTestCase {
    
    var networkManager: NetworkManager!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        networkManager = NetworkManager()
        // Note: In a real implementation, you would inject the mock session
    }
    
//    func testNetworkError() {
//        XCTAssertEqual(NetworkError.invalidURL.localizedDescription, "Invalid URL")
//        XCTAssertEqual(NetworkError.serverError.localizedDescription, "Server error occurred")
//        XCTAssertEqual(NetworkError.decodingError.localizedDescription, "Failed to decode data")
//        XCTAssertEqual(NetworkError.noData.localizedDescription, "No data received")
//    }
}
