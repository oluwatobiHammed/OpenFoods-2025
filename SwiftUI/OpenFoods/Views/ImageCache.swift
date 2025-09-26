//
//  ImageCache.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import Foundation
import UIKit


// MARK: - Image Cache
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func get(forKey key: String) -> UIImage? {
        return cache.object(forKey: NSString(string: key))
    }
    
    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: NSString(string: key))
    }
}
