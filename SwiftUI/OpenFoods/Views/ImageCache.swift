//
//  ImageCache.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import Foundation
import UIKit


// MARK: - Image Cache
/// A lightweight, in-memory image cache built on top of `NSCache`.
///
/// ImageCache provides a simple, thread-safe way to store and retrieve `UIImage`
/// instances by string keys (e.g., URL strings). It is implemented as a singleton
/// to offer a shared cache across the app, minimizing duplicate image decoding and
/// network fetches.
///
/// - Important: This cache is memory-only. Items may be evicted automatically under
///   memory pressure, and contents are not persisted across app launches.
/// - Thread Safety: `NSCache` is thread-safe, so reads and writes can be performed
///   from background or main threads without additional synchronization.
/// - SeeAlso: `NSCache`, `UIImage`
///
/// ## Example
/// ```swift
/// let cache = ImageCache.shared
/// let key = "https://example.com/image.png"
///
/// if let image = cache.get(forKey: key) {
///     imageView.image = image
/// } else {
///     // Download image, then:
///     cache.set(downloadedImage, forKey: key)
///     imageView.image = downloadedImage
/// }
/// ```

/// The shared singleton instance used throughout the app.
///
/// Use this instance to access the cache rather than creating new instances,
/// ensuring consistent memory usage and reuse of cached images.

/// The underlying `NSCache` storing images keyed by `NSString`.
///
/// `NSCache` automatically evicts objects under memory pressure and is safe
/// to use from multiple threads.

/// Creates a new cache instance.
///
/// This initializer is private to enforce the singleton usage pattern.
/// Use ``ImageCache/shared`` instead.

/// Returns a cached image for the given key, if available.
///
/// - Parameter key: The unique identifier for the image (commonly a URL string).
/// - Returns: The cached `UIImage` if present; otherwise, `nil`.
/// - Note: This method does not perform any I/O or decoding; it is an O(1) lookup.

/// Stores an image in the cache under the given key, replacing any existing value.
///
/// - Parameters:
///   - image: The `UIImage` to cache.
///   - key: The unique identifier for the image (commonly a URL string).
/// - Note: Images may be evicted automatically by the system under memory pressure.
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
