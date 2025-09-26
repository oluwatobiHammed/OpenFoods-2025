//
//  ImageCacheManager.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

// MARK: - Image Cache Manager
import UIKit

class ImageCacheManager: ObservableObject {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Set up cache configuration
        cache.countLimit = 100 // Maximum 100 images in memory
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB memory limit
        
        // Create cache directory
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheDirectory = documentsPath.appendingPathComponent("ImageCache")
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        
        // Clean old cache on init
        cleanOldCache()
    }
    
    func getImage(from url: String) -> UIImage? {
        let key = NSString(string: url)
        
        // Check memory cache first
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }
        
        // Check disk cache
        if let diskImage = loadFromDisk(url: url) {
            // Store back in memory cache
            cache.setObject(diskImage, forKey: key)
            return diskImage
        }
        
        return nil
    }
    
    func cacheImage(_ image: UIImage, for url: String) {
        let key = NSString(string: url)
        
        // Store in memory cache
        cache.setObject(image, forKey: key)
        
        // Store in disk cache
        saveToDisk(image: image, url: url)
    }
    
    private func loadFromDisk(url: String) -> UIImage? {
        let fileName = url.sha256()
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    private func saveToDisk(image: UIImage, url: String) {
        let fileName = url.sha256()
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        try? data.write(to: fileURL)
    }
    
    private func cleanOldCache() {
        let currentDate = Date()
        let maxAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days
        
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.creationDateKey]) else {
            return
        }
        
        for file in files {
            if let creationDate = try? file.resourceValues(forKeys: [.creationDateKey]).creationDate,
               currentDate.timeIntervalSince(creationDate) > maxAge {
                try? fileManager.removeItem(at: file)
            }
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func getCacheSize() -> String {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return "0 MB"
        }
        
        let totalSize = files.compactMap { file in
            try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize
        }.reduce(0, +)
        
        let sizeInMB = Double(totalSize) / (1024 * 1024)
        return String(format: "%.1f MB", sizeInMB)
    }
}
