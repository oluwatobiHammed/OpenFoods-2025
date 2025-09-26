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
    
    /**
     Saves a collection of foods to local storage and updates the last sync timestamp.
     
     This method attempts to JSON-encode the provided array of `Food` items and persist
     the resulting data in `UserDefaults` under an internal cache key. On successful
     encoding, it also records the current date as the last successful sync time.
     
     - Parameter foods: The array of `Food` items to cache locally.
     
     - Important:
     - This operation overwrites any previously cached foods.
     - If JSON encoding fails, the cache and last sync date remain unchanged (the method fails silently).
     
     - Requirements: `Food` must conform to `Encodable`.
     
     - Performance: Encoding is O(n) in the number of items and their payload size. Consider calling this from a background context for large datasets.
     
 - Thread Safety: Not inherently thread-safe; concurrent calls may result in last-writer-wins behavior.

 - SeeAlso:
   - `loadFoods()` to retrieve the cached foods.
   - `getLastSyncDate()` to retrieve the last successful sync timestamp.
   - `clearAllData()` to clear the cache and related metadata.
 */
    func saveFoods(_ foods: [Food]) {
        if let encoded = try? JSONEncoder().encode(foods) {
            userDefaults.set(encoded, forKey: foodsKey)
            userDefaults.set(Date(), forKey: lastSyncKey)
        }
    }
    
    /**
     Loads cached `Food` items from local storage.
     
     This method attempts to retrieve previously saved data from `UserDefaults` using an internal cache key
     and JSON-decodes it into an array of `Food`. If the data is missing or decoding fails, the method
     returns an empty array instead of throwing.
     
     - Returns: An array of cached `Food` items, or an empty array if no cache exists or decoding fails.
     
     - Important:
     - This method never throws; failure to decode results in `[]`.
     - The returned data reflects the last successful call to `saveFoods(_:)` and is independent of the last sync timestamp.
     
     - Requirements: `Food` must conform to `Decodable` and be compatible with the encoding used by `saveFoods(_:)`.
     
     - Performance: Decoding is O(n) in the number and size of items. For large datasets, consider calling from a background context.
     
     - Thread Safety: Safe to call from any thread. No mutations are performed.

 - Side Effects: None. This method does not modify the cache or the last sync date.

 - SeeAlso:
   - `saveFoods(_:)` to persist foods to local storage.
   - `getLastSyncDate()` to check when the cache was last updated.
   - `clearAllData()` to remove cached foods and related metadata.
 */
    func loadFoods() -> [Food] {
        guard let data = userDefaults.data(forKey: foodsKey),
              let foods = try? [Food].decode(data: data) else {
            return []
        }
        return foods
    }
    
    
    /**
     Retrieves the timestamp of the last successful local cache sync.
     
     This method reads a `Date` value from `UserDefaults` using an internal key that is
     updated when `saveFoods(_:)` completes successfully. If the app has never synced
     or the value has been cleared, this method returns `nil`.
     
     - Returns: The `Date` of the last successful sync, or `nil` if no sync has occurred.
     
     - Important:
     - The timestamp reflects when the local cache was last updated, not necessarily the remote server time.
     - `clearAllData()` removes this value.
     
     - Performance: Constant time; negligible overhead.
     
     - Thread Safety: Safe to call from any thread. This method performs a read-only lookup.
     
 - Side Effects: None.

 - SeeAlso:
   - `saveFoods(_:)` which updates the last sync date.
   - `loadFoods()` to read cached foods.
   - `clearAllData()` to reset cached data and metadata.
 */
    func getLastSyncDate() -> Date? {
        return userDefaults.object(forKey: lastSyncKey) as? Date
    }
    
    /**
     Queues a pending "like" state for a specific food item for later synchronization.
     
     This method updates an in-memory dictionary of pending like states (keyed by the stringified `foodId`)
     and persists it to `UserDefaults` as JSON. It is designed for scenarios where a user toggles a like
     while offline or before the app has synchronized with a backend. The stored value represents the
     most recent intent for that `foodId`.
     
     - Parameters:
     - foodId: The unique identifier of the food whose like state should be queued.
     - isLiked: The desired like state to persist (`true` to like, `false` to unlike).
     
     - Behavior:
     - Merges with existing pending likes; the entry for `foodId` is overwritten with the new value.
     - If no pending likes exist, a new dictionary is created.
     - A value of `false` is stored explicitly; use `clearPendingLike(foodId:)` to remove an entry entirely.
     - If JSON encoding fails, no changes are written (fails silently).
     
     - Important:
     - This method writes to `UserDefaults` and is not intended for sensitive data.
     - Not inherently thread-safe; concurrent calls may result in last-writer-wins behavior.
     
     - Performance:
     - O(n) relative to the number of pending likes, due to JSON encoding of the dictionary.
     - Suitable for small to moderate numbers of pending items.
     
     - Side Effects:
   - Persists (or replaces) the entire pending likes dictionary in `UserDefaults`.

 - SeeAlso:
   - `getPendingLikes()` to read all queued like states.
   - `clearPendingLike(foodId:)` to remove a specific pending like entry.
   - `clearAllData()` to remove all cached data, including pending likes.
 */
    func savePendingLike(foodId: Int, isLiked: Bool) {
        var pendingLikes = getPendingLikes()
        pendingLikes[String(foodId)] = isLiked
        
        if let encoded = try? JSONEncoder().encode(pendingLikes) {
            userDefaults.set(encoded, forKey: pendingLikesKey)
        }
    }
    
    /**
     Retrieves all queued like states awaiting synchronization from local storage.
     
     This method attempts to read a JSON-encoded dictionary from `UserDefaults` using an internal key.
     The dictionary maps stringified food identifiers to a Boolean representing the desired like state
     to sync (`true` to like, `false` to unlike). If the data is missing or cannot be decoded, an empty
     dictionary is returned instead of throwing.
     
     - Returns: A dictionary mapping food IDs (as `String`) to their pending like state, or `[:]` if no
     pending likes exist or decoding fails.
     
     - Important:
     - This method never throws; failures result in an empty dictionary.
     - Keys are stringified food IDs (e.g., `"42"`).
     - Values capture the most recent user intent and may not reflect server state until synced.
     - Use `clearPendingLike(foodId:)` to remove a specific entry.
     
     - Performance: Decoding cost is O(n) in the number of pending items; suitable for small to moderate sets.
     
     - Thread Safety: Read-only and safe to call from any thread.
     
 - Side Effects: None.

 - SeeAlso:
   - `savePendingLike(foodId:isLiked:)`
   - `clearPendingLike(foodId:)`
   - `clearAllData()`
 */
    func getPendingLikes() -> [String: Bool] {
        guard let data = userDefaults.data(forKey: pendingLikesKey),
              let likes = try? JSONDecoder().decode([String: Bool].self, from: data) else {
            return [:]
        }
        return likes
    }
    
    /**
     Removes a specific pending like entry from local storage.
     
     This method reads the JSON-encoded dictionary of pending like states from `UserDefaults`,
     removes the entry associated with the provided `foodId` (keyed as `String(foodId)`), and
     persists the updated dictionary back to `UserDefaults`. If the entry does not exist, the
     operation is effectively a no-op, though the (possibly empty) dictionary is still re-saved.
     
     - Parameter foodId: The unique identifier of the food whose pending like state should be removed.
     
     - Behavior:
     - Converts `foodId` to its string representation to match stored keys.
     - Idempotent: Removing a non-existent key leaves the dictionary unchanged.
     - Overwrites the entire pending likes dictionary in `UserDefaults` with the updated value.
     
     - Important:
     - This method writes to `UserDefaults` and is not intended for sensitive data.
     - Not inherently thread-safe; concurrent writes may result in last-writer-wins behavior.
     - If JSON encoding fails, no changes are persisted (fails silently).
     - This does not clear all pending likes; use `clearAllData()` to remove everything.
     
     - Performance:
     - O(n) relative to the number of pending items due to JSON re-encoding of the dictionary.
     - Suitable for small to moderate sets of pending likes.
     
     - Thread Safety:
     - Not synchronized. Prefer serializing calls at a higher level if concurrent writes are possible.
     
     - Side Effects:
   - Persists the updated (possibly empty) pending likes dictionary to `UserDefaults`.
   - May create the pending likes store if it did not previously exist.

 - SeeAlso:
   - `savePendingLike(foodId:isLiked:)`
   - `getPendingLikes()`
   - `clearAllData()`
 */
    func clearPendingLike(foodId: Int) {
        var pendingLikes = getPendingLikes()
        pendingLikes.removeValue(forKey: String(foodId))
        
        if let encoded = try? JSONEncoder().encode(pendingLikes) {
            userDefaults.set(encoded, forKey: pendingLikesKey)
        }
    }
    
    /**
     Clears all locally cached data and related metadata.
     
     This method removes the following entries from `UserDefaults`:
     - The cached foods list.
     - The last successful sync timestamp.
     - All queued (pending) like states.
     
     - Use Cases:
     - Logging a user out.
     - Forcing a full cache reset to recover from corruption or stale data.
     - Preparing the app for a fresh sync cycle.
     
     - Behavior:
     - Idempotent: Missing keys are ignored without error.
     - Does not affect unrelated `UserDefaults` values.
     - Does not clear any in-memory caches your app may hold.
     
     - Returns: `Void`.
     
     - Important:
     - This operation is irreversible; removed data cannot be recovered.
     - If invoked concurrently with other write operations (e.g., `saveFoods(_:)` or `savePendingLike(foodId:isLiked:)`),
     final state depends on call ordering (last-writer-wins).
     
     - Performance:
     - Constant time; negligible overhead.
     
     - Thread Safety:
     - Not synchronized. Consider serializing calls if other code writes to the same keys concurrently.
     
     - Side Effects:
     - Subsequent calls to `loadFoods()` will return an empty array.
     - `getLastSyncDate()` will return `nil`.
     - `getPendingLikes()` will return an empty dictionary.

 - SeeAlso:
   - `saveFoods(_:)` to persist foods to local storage.
   - `loadFoods()` to read cached foods.
   - `getLastSyncDate()` to read the last successful sync timestamp.
   - `savePendingLike(foodId:isLiked:)` to queue a like/unlike state.
   - `getPendingLikes()` to retrieve queued like states.
   - `clearPendingLike(foodId:)` to remove a specific pending like entry.
 */
    func clearAllData() {
        userDefaults.removeObject(forKey: foodsKey)
        userDefaults.removeObject(forKey: lastSyncKey)
        userDefaults.removeObject(forKey: pendingLikesKey)
    }
}
