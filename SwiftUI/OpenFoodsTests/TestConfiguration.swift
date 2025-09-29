//
//  TestConfiguration.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-28.
//

import Foundation

// MARK: - Test Configuration
class TestConfiguration {
    static let shared = TestConfiguration()
    
    var isUITesting: Bool {
        return ProcessInfo.processInfo.arguments.contains("UI_TESTING")
    }
    
    var shouldUseMockData: Bool {
        return ProcessInfo.processInfo.arguments.contains("USE_MOCK_DATA")
    }
}
