//
//  NetworkResponseTests.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-28.
//

import XCTest
@testable import OpenFoods

// MARK: - Network Response Tests
class NetworkResponseTests: XCTestCase {
    
    func testSuccessResponse() {
        let response200 = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let result200 = handleNetworkResponse(response200)
        
        switch result200 {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail("200 should be success")
        }
        
        let response299 = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 299, httpVersion: nil, headerFields: nil)!
        let result299 = handleNetworkResponse(response299)
        
        switch result299 {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail("299 should be success")
        }
    }
    
    func testNotFoundResponse() {
        let response404 = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
        let result = handleNetworkResponse(response404)
        
        switch result {
        case .success:
            XCTAssertTrue(true) // 404 is treated as success in your implementation
        case .failure:
            XCTFail("404 should be success according to handleNetworkResponse")
        }
    }
    
    func testAuthenticationError() {
        let response401 = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)!
        let result = handleNetworkResponse(response401)
        
        switch result {
        case .success:
            XCTFail("401 should be failure")
        case .failure(let error):
            XCTAssertEqual((error as NSError).code, 401)
            XCTAssertTrue((error as NSError).localizedDescription.contains("authenticated"))
        }
    }
    
    func testBadRequestError() {
        let response501 = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 501, httpVersion: nil, headerFields: nil)!
        let result = handleNetworkResponse(response501)
        
        switch result {
        case .success:
            XCTFail("501 should be failure")
        case .failure(let error):
            XCTAssertEqual((error as NSError).code, 501)
        }
    }
    
    func testOutdatedError() {
        let response600 = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 600, httpVersion: nil, headerFields: nil)!
        let result = handleNetworkResponse(response600)
        
        switch result {
        case .success:
            XCTFail("600 should be failure")
        case .failure(let error):
            XCTAssertEqual((error as NSError).code, 600)
        }
    }
    
    func testUnknownError() {
        let response1000 = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 1000, httpVersion: nil, headerFields: nil)!
        let result = handleNetworkResponse(response1000)
        
        switch result {
        case .success:
            XCTFail("1000 should be failure")
        case .failure(let error):
            XCTAssertEqual((error as NSError).code, 1000)
        }
    }
}
