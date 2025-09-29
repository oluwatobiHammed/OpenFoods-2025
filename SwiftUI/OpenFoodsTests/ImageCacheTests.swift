//
//  ImageCacheTests.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-28.
//

import UIKit
import XCTest
@testable import OpenFoods

// MARK: - Image Cache Tests
class ImageCacheTests: XCTestCase {
    
    var imageCache: ImageCache!
    
    override func setUp() {
        super.setUp()
        imageCache = ImageCache.shared
    }
    
    func testImageCacheSetAndGet() {
        let testImage = UIImage(systemName: "heart.fill")!
        let testKey = "test_image_key_123"
        
        XCTAssertNil(imageCache.get(forKey: testKey))
        
        imageCache.set(testImage, forKey: testKey)
        
        let cachedImage = imageCache.get(forKey: testKey)
        XCTAssertNotNil(cachedImage)
    }
    
    func testImageCacheOverwrite() {
        let firstImage = UIImage(systemName: "heart")!
        let secondImage = UIImage(systemName: "star.fill")!
        let testKey = "test_image_key_456"
        
        imageCache.set(firstImage, forKey: testKey)
        XCTAssertNotNil(imageCache.get(forKey: testKey))
        
        imageCache.set(secondImage, forKey: testKey)
        XCTAssertNotNil(imageCache.get(forKey: testKey))
    }
    
    func testMultipleImagesCaching() {
        let image1 = UIImage(systemName: "heart")!
        let image2 = UIImage(systemName: "star")!
        let image3 = UIImage(systemName: "circle")!
        
        imageCache.set(image1, forKey: "key1")
        imageCache.set(image2, forKey: "key2")
        imageCache.set(image3, forKey: "key3")
        
        XCTAssertNotNil(imageCache.get(forKey: "key1"))
        XCTAssertNotNil(imageCache.get(forKey: "key2"))
        XCTAssertNotNil(imageCache.get(forKey: "key3"))
    }
}
