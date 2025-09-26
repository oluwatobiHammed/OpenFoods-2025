//
//  LocalStorageManager.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import Foundation

// MARK: - Local Storage Manager
class LocalStorageManager {
    static let shared = LocalStorageManager()
    private let userDefaults = UserDefaults.standard
    private let foodsKey = "cached_foods"
    private let lastSyncKey = "last_sync_date"
    private let pendingLikesKey = "pending_likes"
    
    private init() {}
    
    func saveFoods(_ foods: [Food]) {
        if let encoded = try? JSONEncoder().encode(foods) {
            userDefaults.set(encoded, forKey: foodsKey)
            userDefaults.set(Date(), forKey: lastSyncKey)
        }
    }
    
    func loadFoods() -> [Food] {
        guard let data = userDefaults.data(forKey: foodsKey),
              let foods = try? [Food].decode(data: data) else {
            return []
        }
        return foods
    }
    
    func getLastSyncDate() -> Date? {
        return userDefaults.object(forKey: lastSyncKey) as? Date
    }
    
    func savePendingLike(foodId: Int, isLiked: Bool) {
        var pendingLikes = getPendingLikes()
        pendingLikes[String(foodId)] = isLiked
        
        if let encoded = try? JSONEncoder().encode(pendingLikes) {
            userDefaults.set(encoded, forKey: pendingLikesKey)
        }
    }
    
    func getPendingLikes() -> [String: Bool] {
        guard let data = userDefaults.data(forKey: pendingLikesKey),
              let likes = try? JSONDecoder().decode([String: Bool].self, from: data) else {
            return [:]
        }
        return likes
    }
    
    func clearPendingLike(foodId: Int) {
        var pendingLikes = getPendingLikes()
        pendingLikes.removeValue(forKey: String(foodId))
        
        if let encoded = try? JSONEncoder().encode(pendingLikes) {
            userDefaults.set(encoded, forKey: pendingLikesKey)
        }
    }
    
    func clearAllData() {
        userDefaults.removeObject(forKey: foodsKey)
        userDefaults.removeObject(forKey: lastSyncKey)
        userDefaults.removeObject(forKey: pendingLikesKey)
    }
}
