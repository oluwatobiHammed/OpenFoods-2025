//
//  FoodListViewModel.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import Foundation
import  Combine

@MainActor
// MARK: - View Model
class FoodListViewModel: ObservableObject {
    @Published var foods: [Food] = []
    @Published var food: Food?
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasError = false
    @Published var errorMessage = ""
    @Published var isOfflineMode = false
    
    private var networkManager: NetworkManager
    private let localStorageManager = LocalStorageManager.shared
    private let networkMonitor = NetworkMonitor()
    private var currentPage = 0
    private var totalCount = 0
    private var canLoadMore = true
    private var cancellables = Set<AnyCancellable>()
    
    
    
    init(networkManager: NetworkManager = NetworkManager()) {
        
        self.networkManager = networkManager
        // Load cached data immediately
        
        // Load cached data on main actor
        
        loadCachedFoods()
        
        
        // Monitor network status
        networkMonitor.$isConnected
            .sink { [weak self] isConnected in
                guard let self else { return }
                
                handleNetworkStatusChange(isConnected: isConnected)
                
            }
            .store(in: &cancellables)
    }
   
    
    /// Configures the view model by performing the initial data load.
    ///
    /// This method triggers the same behavior as calling ``loadFoods()``:
    /// - Displays any cached foods immediately (if available).
    /// - If offline, enables offline mode and only surfaces an error when no cached data exists.
    /// - If online, fetches the first page of foods, persists them to local storage, and applies any pending likes.
    /// - Updates published properties such as `foods`, `isLoading`, `hasError`, `errorMessage`, and `isOfflineMode`.
    ///
    /// Usage:
    /// Call this from a SwiftUI `.task` or any async lifecycle hook to kick off the initial load:
    /// ```swift
    /// .task { await viewModel.configure() }
    /// ```
    ///
    /// - Important: This method is `async`, must be awaited, and runs on the main actor.
    /// - Note: Safe to call multiple times; each call refreshes the list according to current network state and cache.
    /// - SeeAlso: ``loadFoods()``
    func configure() async {
        
        await loadFoods()
    }
    
 
    /// Loads any previously cached foods from local storage and updates the view model state.
    ///
    /// - Discussion:
    ///   - Reads persisted foods via `LocalStorageManager.loadFoods()`.
    ///   - If the cache is non-empty, assigns the result to the published `foods` array
    ///     and invokes `applyPendingLikes()` so that any offline like/unlike actions are
    ///     reflected in the UI.
    ///   - If the cache is empty, the method leaves the current state unchanged.
    ///   - This method performs no network requests.
    ///
    /// - Effects:
    ///   - Mutates `foods`, which will trigger UI updates for observers.
    ///   - May adjust each item's `isLiked` based on locally stored pending likes.
    ///
    /// - Concurrency:
    ///   - Intended to run on the main actor (the enclosing type is annotated with `@MainActor`).
    ///
    /// - SeeAlso:
    ///   - `applyPendingLikes()`
    ///   - `LocalStorageManager.loadFoods()`
    ///   - `LocalStorageManager.saveFoods(_:)`
    private func loadCachedFoods() {
        let cachedFoods = localStorageManager.loadFoods()
        if !cachedFoods.isEmpty {
            foods = cachedFoods
            applyPendingLikes()
        }
    }
    
    
    /// Handles network connectivity changes and updates offline/online state.
    ///
    /// - Behavior:
    ///   - When `isConnected` is `true` and the view model is currently in offline mode:
    ///     - Sets `isOfflineMode` to `false`.
    ///     - Launches a `Task` to:
    ///       - Call `syncPendingLikes()` to push any locally queued like/unlike actions to the server.
    ///       - Call `refreshFoods()` to reload data from the network and update the cache/UI.
    ///   - When `isConnected` is `false`:
    ///     - Sets `isOfflineMode` to `true` so the UI can reflect offline status and rely on cached data.
    ///
    /// - Discussion:
    ///   This method is invoked by the `NetworkMonitor.$isConnected` subscription set up in `init`.
    ///   It does not block the main thread; longer operations are dispatched inside an asynchronous `Task`.
    ///
    /// - Effects:
    ///   - Mutates `isOfflineMode`.
    ///   - May trigger network requests through `syncPendingLikes()` and `refreshFoods()`.
    ///   - Indirectly updates `foods`, `hasError`, `errorMessage`, and local cache via `refreshFoods()`.
    ///
    /// - Concurrency:
    ///   - Runs on the main actor (the enclosing type is annotated with `@MainActor`).
    ///   - Uses `Task` to perform asynchronous work without awaiting inline.
    ///
    /// - Parameter isConnected: A Boolean indicating whether the device currently has network connectivity.
    ///
    /// - SeeAlso: `syncPendingLikes()`, `refreshFoods()`, `NetworkMonitor`
    private func handleNetworkStatusChange(isConnected: Bool) {
        if isConnected && isOfflineMode {
            isOfflineMode = false
            // Sync pending likes when coming back online
            Task {
                await syncPendingLikes()
                await refreshFoods()
            }
        } else if !isConnected {
            isOfflineMode = true
        }
    }
    
    
  
    /// Applies any locally stored pending like/unlike states to the in-memory `foods` array.
    ///
    /// - Behavior:
    ///   - Reads pending likes via `LocalStorageManager.getPendingLikes()`, which returns a map of `foodId (String) -> isLiked (Bool)`.
    ///   - For each entry, attempts to convert the `foodId` to `Int` and locate a matching item in `foods` by `id`.
    ///   - If found, updates that item's `isLiked` property to the stored value.
    ///   - Items not present in the current `foods` collection are ignored.
    ///
    /// - When to Call:
    ///   - Immediately after loading cached foods from disk (e.g., in `loadCachedFoods()`).
    ///   - After fetching foods from the network to reflect any offline like/unlike actions before showing the UI.
    ///
    /// - Effects:
    ///   - Mutates `foods`, triggering UI updates for observers.
    ///   - Performs no network requests and does not write to disk.
    ///   - Does not clear pending likes; they remain until `syncPendingLikes()` succeeds.
    ///
    /// - Concurrency:
    ///   - Intended to run on the main actor (the enclosing type is annotated with `@MainActor`).
    ///
    /// - Complexity:
    ///   - Worst case O(P × N), where P is the number of pending likes and N is the number of items in `foods`.
    ///
    /// - SeeAlso:
    ///   - `toggleLike(for:)`
    ///   - `syncPendingLikes()`
    ///   - `loadCachedFoods()`
    ///   - `LocalStorageManager.getPendingLikes()`
    private func applyPendingLikes() {
        let pendingLikes = localStorageManager.getPendingLikes()
        
        for (foodIdString, isLiked) in pendingLikes {
            if let foodId = Int(foodIdString),
               let index = foods.firstIndex(where: { $0.id == foodId }) {
                foods[index].isLiked = isLiked
            }
        }
    }
    
    
    /// Attempts to synchronize locally queued like/unlike actions with the backend service.
    ///
    /// - Overview:
    ///   This method reads the pending like states stored by `LocalStorageManager.getPendingLikes()`
    ///   (a dictionary mapping `foodId` as `String` to `isLiked` as `Bool`) and tries to push each
    ///   operation to the server using `NetworkManager`. For each entry:
    ///   - Converts the `foodId` string to an `Int`.
    ///   - If `isLiked` is `true`, calls `NetworkManager.likeFood(id:)`.
    ///   - If `isLiked` is `false`, calls `NetworkManager.unlikeFood(id:)`.
    ///   - On success (`true`), removes that item from the pending likes via
    ///     `LocalStorageManager.clearPendingLike(foodId:)`.
    ///   - On failure (thrown error or unsuccessful response), leaves the pending entry intact so
    ///     it can be retried later and logs the error.
    ///
    /// - Behavior:
    ///   - Does not mutate the in-memory `foods` array directly; UI should already reflect pending
    ///     like/unlike states via `applyPendingLikes()`.
    ///   - Swallows errors and continues processing remaining items; failures are logged with `print`.
    ///   - Safe to call multiple times; only successfully synced items are cleared.
    ///
    /// - Concurrency:
    ///   - `async`; must be awaited by callers.
    ///   - Runs on the main actor because the enclosing type is annotated with `@MainActor`.
    ///     Network calls are awaited asynchronously.
    ///
    /// - Performance:
    ///   - Time complexity: O(P), where P is the number of pending likes.
    ///   - Network-bound; total duration depends on backend latency and number of items.
    ///
    /// - When to Call:
    ///   - After regaining connectivity (e.g., in `handleNetworkStatusChange(isConnected:)`).
    ///   - During app startup or foregrounding to flush any backlog of pending operations.
    ///
    /// - Preconditions:
    ///   - Network connectivity is recommended; the method itself does not verify connectivity
    ///     and will attempt requests regardless.
    ///
    /// - Side Effects:
    ///   - May modify local persistence by clearing individual pending like entries upon success.
    ///   - Logs errors to the console for troubleshooting.
    ///
    /// - Note:
    ///   - This method does not throw. Any failures are intentionally absorbed to preserve pending
    ///     actions for future retries.
    ///
    /// - Example:
    ///   ```swift
    ///   // Flush any offline like/unlike actions when the app becomes online
    ///   Task { await viewModel.syncPendingLikes() }
    ///   ```
    ///
    /// - SeeAlso:
    ///   - ``applyPendingLikes()``
    ///   - ``toggleLike(for:)``
    ///   - ``handleNetworkStatusChange(isConnected:)``
    ///   - `LocalStorageManager.getPendingLikes()`
    ///   - `LocalStorageManager.clearPendingLike(foodId:)`
    ///   - `NetworkManager.likeFood(id:)`
    ///   - `NetworkManager.unlikeFood(id:)`
    private func syncPendingLikes() async {
        
        let pendingLikes = localStorageManager.getPendingLikes()
        
        for (foodIdString, isLiked) in pendingLikes {
            if let foodId = Int(foodIdString) {
                do {
                    let success = if isLiked {
                        try await networkManager.likeFood(id: foodId)
                    } else {
                        try await networkManager.unlikeFood(id: foodId)
                    }
                    
                    if success {
                        localStorageManager.clearPendingLike(foodId: foodId)
                    }
                } catch {
                    // Keep pending like for retry later
                    print("Failed to sync like for food \(foodId): \(error)")
                }
            }
        }
    }
    
    
    /// Loads the first page of foods, favoring cached content and handling offline scenarios gracefully.
    ///
    /// - Overview:
    ///   - Displays any cached foods immediately if the in-memory list is empty by calling `loadCachedFoods()`
    ///     (which also applies any pending like/unlike states to the cached items).
    ///   - If the device is offline, enables offline mode and, if no cached data exists, surfaces an error and returns.
    ///   - If online, fetches page 0 from the backend, updates pagination state, persists the results to local storage,
    ///     reapplies any pending like/unlike states, and disables offline mode.
    ///
    /// - Behavior:
    ///   - If `foods` is empty:
    ///     - Calls `loadCachedFoods()` to show cached items right away.
    ///   - If `NetworkMonitor.isConnected == false`:
    ///     - Sets `isOfflineMode = true`.
    ///     - If `foods` is still empty after attempting to load cache:
    ///       - Sets `hasError = true` and `errorMessage = "No internet connection and no cached data available"`.
    ///     - Returns early without making a network request.
    ///   - If online:
    ///     - Sets `isLoading = true`, `hasError = false`, and resets pagination by setting `currentPage = 0`.
    ///     - Awaits `NetworkManager.fetchFoods(page:)` for the first page.
    ///     - Updates:
    ///       - `foods` with the fetched items,
    ///       - `totalCount` with the server-reported total,
    ///       - `canLoadMore` based on `foods.count < totalCount`.
    ///     - Persists the fetched items via `LocalStorageManager.saveFoods(_:)`.
    ///     - Calls `applyPendingLikes()` to reflect any offline like/unlike actions.
    ///     - Sets `isOfflineMode = false`.
    ///   - On network failure:
    ///     - If there are no items in `foods`:
    ///       - Sets `hasError = true` and `errorMessage = error.localizedDescription`.
    ///     - Otherwise:
    ///       - Keeps showing the existing (likely cached) list and sets `isOfflineMode = true`.
    ///   - Always clears the loading indicator by setting `isLoading = false` before returning.
    ///
    /// - Side Effects:
    ///   - Mutates multiple `@Published` properties: `foods`, `isLoading`, `hasError`, `errorMessage`,
    ///     `isOfflineMode`, `currentPage`, `totalCount`, and `canLoadMore`.
    ///   - Writes to disk via `LocalStorageManager.saveFoods(_:)`.
    ///
    /// - Concurrency:
    ///   - `async`; must be awaited by callers.
    ///   - Runs on the main actor (the enclosing type is annotated with `@MainActor`).
    ///
    /// - Performance:
    ///   - Network-bound; duration depends on backend latency and payload size.
    ///   - Applies pending likes in-memory with linear passes over the current items.
    ///
    /// - Preconditions:
    ///   - None. The method is resilient to lack of connectivity and missing cache.
    ///
    /// - Postconditions:
    ///   - On success: The in-memory list and cache are refreshed with page 0, and pending likes are reflected.
    ///   - On failure with cache present: The UI continues to show cached data and indicates offline mode.
    ///   - On failure without cache: An error state is presented.
    ///
    /// - Usage:
    ///   ```swift
    ///   .task { await viewModel.loadFoods() }
    ///   ```
    ///
    /// - SeeAlso:
    ///   - `configure()`
    ///   - `refreshFoods()`
    ///   - `loadMoreFoodsIfNeeded()`
    ///   - `applyPendingLikes()`
    ///   - `LocalStorageManager.saveFoods(_:)`
    ///   - `NetworkManager.fetchFoods(page:)`
    ///   - `NetworkMonitor.isConnected`
     func loadFoods() async {
         
         // Always show cached data first
         if foods.isEmpty {
             loadCachedFoods()
         }
         
         // If offline, don't attempt network call
         if !networkMonitor.isConnected {
             isOfflineMode = true
             if foods.isEmpty {
                 hasError = true
                 errorMessage = "No internet connection and no cached data available"
             }
             return
         }
         
         isLoading = true
         hasError = false
         currentPage = 0
         
         do {
             let response = try await networkManager.fetchFoods(page: currentPage)
             foods = response.foods
             totalCount = response.totalCount
             canLoadMore = foods.count < totalCount
             
             // Save to local storage
             localStorageManager.saveFoods(foods)
             
             // Apply any pending likes
             applyPendingLikes()
             
             isOfflineMode = false
         } catch {
             // If we have cached data, show it instead of error
             if foods.isEmpty {
                 hasError = true
                 errorMessage = error.localizedDescription
             } else {
                 // Show cached data with offline indicator
                 isOfflineMode = true
             }
         }
         
         isLoading = false
     }
    
    /// Loads the next page of foods when pagination conditions are met.
    ///
    /// - Overview:
    ///   Triggers a paginated network request to fetch the next page of foods and appends
    ///   the results to the in-memory list. The method is guarded to avoid duplicate
    ///   requests, concurrent loads, initial loads, and offline scenarios. On success,
    ///   the combined list is persisted to local storage. On failure, pagination state
    ///   is rolled back and an error is surfaced.
    ///
    /// - Behavior:
    ///   - Early-exits unless all of the following are true:
    ///     - `canLoadMore == true` (more pages are expected),
    ///     - `isLoadingMore == false` (no existing pagination request in-flight),
    ///     - `isLoading == false` (not currently performing the initial load/refresh),
    ///     - `isOfflineMode == false` (device is online).
    ///   - Sets `isLoadingMore = true` and increments `currentPage`.
    ///   - Awaits `NetworkManager.fetchFoods(page:)` for the next page.
    ///   - On success:
    ///     - Appends the fetched items to `foods`.
    ///     - Updates `canLoadMore` based on `foods.count < totalCount`.
    ///     - Persists the full `foods` array via `LocalStorageManager.saveFoods(_:)`.
    ///   - On failure:
    ///     - Decrements `currentPage` to undo the increment.
    ///     - Sets `hasError = true` and assigns `errorMessage` with the failure description.
    ///   - Always sets `isLoadingMore = false` before returning.
    ///
    /// - Side Effects:
    ///   - Mutates `foods`, `isLoadingMore`, `currentPage`, `canLoadMore`, `hasError`, and `errorMessage`.
    ///   - Writes to disk by saving the updated `foods` to local storage.
    ///
    /// - Concurrency:
    ///   - `async`; must be awaited by callers.
    ///   - Runs on the main actor (the enclosing type is annotated with `@MainActor`).
    ///
    /// - Performance:
    ///   - Network-bound; duration depends on backend latency and payload size.
    ///   - Appending items is O(k), where k is the number of new items. Persisting the full list may be O(n).
    ///
    /// - Preconditions:
    ///   - `totalCount` should have been set by a prior successful call to `loadFoods()`.
    ///
    /// - Postconditions:
    ///   - On success: `foods` includes the next page and `canLoadMore` reflects remaining items.
    ///   - On failure: Pagination index is restored and an error state is presented.
    ///
    /// - Usage:
    ///   Call when the user approaches the end of the list (e.g., on appear of the last cell or via a scroll threshold):
    ///   ```swift
    ///   .task { await viewModel.loadMoreFoodsIfNeeded() }
    ///   ```
    ///
    /// - SeeAlso:
    ///   - `loadFoods()`
    ///   - `refreshFoods()`
    ///   - `NetworkManager.fetchFoods(page:)`
    ///   - `LocalStorageManager.saveFoods(_:)`
    func loadMoreFoodsIfNeeded() async {
         guard canLoadMore && !isLoadingMore && !isLoading && !isOfflineMode else { return }
         
         isLoadingMore = true
         currentPage += 1
         
         do {
             let response = try await networkManager.fetchFoods(page: currentPage)
             foods.append(contentsOf: response.foods)
             canLoadMore = foods.count < totalCount
             
             // Update local storage with all foods
             localStorageManager.saveFoods(foods)
             
         } catch {
             currentPage -= 1 // Reset page on error
             hasError = true
             errorMessage = error.localizedDescription
         }
         
         isLoadingMore = false
     }
    
   
    /// Refreshes the foods list by delegating to ``loadFoods()``.
    ///
    /// - Overview:
    ///   - This convenience method simply calls ``loadFoods()`` to re-fetch and/or display the list,
    ///     preserving all of that method’s behavior:
    ///     - Shows any cached items immediately if available,
    ///     - Handles offline scenarios gracefully (surfacing an error only when no cache exists),
    ///     - When online, fetches the first page, updates pagination state, persists results, and reapplies pending likes.
    ///   - Use this to explicitly trigger a pull-to-refresh or manual refresh from the UI.
    ///
    /// - Behavior:
    ///   - Mirrors ``loadFoods()`` exactly; see that method’s documentation for full details on
    ///     caching, offline handling, pending likes, and pagination resets.
    ///
    /// - Side Effects:
    ///   - Mutates the same `@Published` properties as ``loadFoods()``:
    ///     `foods`, `isLoading`, `hasError`, `errorMessage`, `isOfflineMode`, `currentPage`,
    ///     `totalCount`, and `canLoadMore`.
    ///   - Persists data to local storage when new content is fetched.
    ///
    /// - Concurrency:
    ///   - `async`; must be awaited by callers.
    ///   - Runs on the main actor (the type is annotated with `@MainActor`).
    ///
    /// - Usage:
    ///   - Ideal for pull-to-refresh in SwiftUI:
    ///   ```swift
    ///   .refreshable { await viewModel.refreshFoods() }
    ///   ```
    ///   - You can also trigger it from a button or lifecycle event:
    ///   ```swift
    ///   Button("Refresh") { Task { await viewModel.refreshFoods() } }
    ///   ```
    ///
    /// - Important:
    ///   - Safe to call multiple times; each call re-applies the same logic as ``loadFoods()``.
    ///
    /// - SeeAlso:
    ///   - ``loadFoods()``
    ///   - ``configure()``
    ///   - ``loadMoreFoodsIfNeeded()``
    ///   - ``applyPendingLikes()``
    func refreshFoods() async {
        await loadFoods()
    }
    
    
    /// Toggles the like state of the given food item with an optimistic UI update and offline persistence.
    ///
    /// - Overview:
    ///   - Immediately flips the `isLiked` flag for the matching item in the in-memory `foods` array
    ///     to provide a responsive UI.
    ///   - Records the new state as a pending like via `LocalStorageManager.savePendingLike(foodId:isLiked:)`,
    ///     and updates the cached list on disk via `LocalStorageManager.saveFoods(_:)`.
    ///   - If the device is online (`NetworkMonitor.isConnected == true`), attempts to sync the change
    ///     with the backend using `NetworkManager.likeFood(id:)` or `NetworkManager.unlikeFood(id:)`.
    ///     On success, the corresponding pending entry is cleared. On failure, the pending entry is kept
    ///     so it can be retried later (e.g., by `syncPendingLikes()`).
    ///   - If the device is offline, the change is retained locally as a pending like and will be synced
    ///     when connectivity returns.
    ///
    /// - Behavior:
    ///   - Optimistic UI: The UI reflects the new like state immediately; it is not rolled back on error.
    ///   - Persistence: The entire `foods` array is written to local storage after the toggle to keep cache in sync.
    ///   - Networking (when online):
    ///     - Calls `likeFood(id:)` if the new state is liked, otherwise `unlikeFood(id:)`.
    ///     - Clears the pending entry only when the server call returns `success == true`.
    ///     - Any thrown error is caught and logged; the pending entry remains for future retry.
    ///   - Offline: No network call is made; the pending entry remains until `syncPendingLikes()` processes it.
    ///
    /// - Concurrency:
    ///   - `async`; must be awaited by callers.
    ///   - Runs on the main actor (the enclosing type is annotated with `@MainActor`).
    ///
    /// - Parameters:
    ///   - food: The `Food` whose like state should be toggled. Must exist in the current `foods` array.
    ///
    /// - Side Effects:
    ///   - Mutates the published `foods` array (triggers UI updates).
    ///   - Writes to disk via `LocalStorageManager.saveFoods(_:)`.
    ///   - Adds or removes entries in the pending likes store (`LocalStorageManager.savePendingLike(...)` / `clearPendingLike(...)`).
    ///   - Logs errors to the console; does not throw.
    ///
    /// - Error Handling:
    ///   - All networking errors are caught internally and logged. The UI change is preserved,
    ///     and the like operation remains pending for future synchronization.
    ///
    /// - Complexity:
    ///   - O(n) to locate the item in `foods` (by id).
    ///   - Disk writes depend on storage implementation; saving the full list is typically O(n).
    ///
    /// - Example:
    ///   ```swift
    ///   // Toggle like from a button tap
    ///   Button {
    ///       Task { await viewModel.toggleLike(for: food) }
    ///   } label: {
    ///       Image(systemName: food.isLiked ? "heart.fill" : "heart")
    ///   }
    ///   ```
    ///
    /// - SeeAlso:
    ///   - ``applyPendingLikes()``
    ///   - ``syncPendingLikes()``
    ///   - `LocalStorageManager.savePendingLike(foodId:isLiked:)`
    ///   - `LocalStorageManager.clearPendingLike(foodId:)`
    ///   - `LocalStorageManager.saveFoods(_:)`
    ///   - `NetworkManager.likeFood(id:)`
    ///   - `NetworkManager.unlikeFood(id:)`
    ///   - `NetworkMonitor.isConnected`
    ///
    /// - Important:
    ///   - This method does not debounce rapid successive taps. Repeated toggles will update the UI each time
    ///     and queue the latest state for synchronization.
    ///   - The method is resilient to connectivity changes; pending operations are intentionally preserved
    ///     until a successful server sync occurs.
    func toggleLike(for food: Food) async {
        guard let index = foods.firstIndex(where: { $0.id == food.id }) else { return }
        
        // Update UI immediately for better UX
        let newLikedState = !food.isLiked
        foods[index].isLiked = newLikedState
        
        // Save pending like locally
        localStorageManager.savePendingLike(foodId: food.id, isLiked: newLikedState)
        
        // Update cached foods
        localStorageManager.saveFoods(foods)
        
        // If online, try to sync immediately
        if networkMonitor.isConnected {
            do {
                let success = if newLikedState {
                    try await networkManager.likeFood(id: food.id)
                } else {
                    try await networkManager.unlikeFood(id: food.id)
                }
                
                if success {
                    // Remove from pending likes as it was successfully synced
                    localStorageManager.clearPendingLike(foodId: food.id)
                } else {
                    // Keep in pending likes for retry later
                    print("Like operation returned success=false for food \(food.id)")
                }
            } catch {
                // Keep the UI change but store as pending
                print("Failed to sync like immediately: \(error.localizedDescription)")
                // The like is already saved as pending, so it will be retried when online
            }
        }
    }
    
    /// Clears all locally cached data and resets in-memory state to initial values.
    ///
    /// - Overview:
    ///   - Invokes `LocalStorageManager.clearAllData()` to remove any locally persisted data
    ///     (e.g., cached foods, pending likes, and metadata such as last sync date).
    ///   - Empties the in-memory `foods` array and resets pagination-related properties.
    ///   - Does not initiate any network requests.
    ///
    /// - Behavior:
    ///   - Sets:
    ///     - `foods = []`
    ///     - `currentPage = 0`
    ///     - `totalCount = 0`
    ///     - `canLoadMore = true`
    ///   - Leaves `isLoading`, `isLoadingMore`, `hasError`, `errorMessage`, and `isOfflineMode` unchanged.
    ///
    /// - Side Effects:
    ///   - Publishes an empty `foods` list, causing the UI to render no items.
    ///   - Removes any locally stored cache and pending like operations (depending on `LocalStorageManager` implementation).
    ///
    /// - Concurrency:
    ///   - Runs on the main actor (the enclosing type is annotated with `@MainActor`).
    ///
    /// - When to Call:
    ///   - From a “Reset cache” action (e.g., in Settings), or to recover from inconsistent local state.
    ///   - Prior to forcing a full fresh reload (e.g., call `loadFoods()` after clearing).
    ///
    /// - Postconditions:
    ///   - The view model is in a clean state with no cached items; subsequent loads will start from page 0.
    ///
    /// - Important:
    ///   - This operation is destructive and cannot be undone. If you intend to preserve pending like/unlike actions
    ///     for later synchronization, avoid clearing the cache.
    ///
    /// - Usage:
    ///   ```swift
    ///   Button("Clear Cache") {
    ///       viewModel.clearCache()
    ///       Task { await viewModel.loadFoods() } // optional: trigger a fresh load
    ///   }
    ///   ```
    ///
    /// - SeeAlso:
    ///   - `LocalStorageManager.clearAllData()`
    ///   - `loadFoods()`
    ///   - `refreshFoods()`
    ///   - `getCacheInfo()`
    func clearCache() {
        localStorageManager.clearAllData()
        foods = []
        currentPage = 0
        totalCount = 0
        canLoadMore = true
    }
    
    /// Returns lightweight cache metadata suitable for displaying status to the user or
    /// for diagnostics (e.g., “Last synced …”, “3 actions pending”).
    ///
    /// - Overview:
    ///   - Reads the most recent successful sync date and the number of locally queued
    ///     like/unlike operations from `LocalStorageManager`.
    ///   - This method is read-only; it does not modify in-memory state or write to disk.
    ///   - No network requests are performed.
    ///
    /// - Returns:
    ///   A tuple containing:
    ///   - `lastSync`: The date when the foods list was last successfully saved to local storage,
    ///     as reported by `LocalStorageManager`. `nil` if a sync has never occurred.
    ///   - `pendingLikesCount`: The number of pending like/unlike operations that are stored locally
    ///     and awaiting synchronization with the backend.
    ///
    /// - Discussion:
    ///   Use this information to:
    ///   - Inform users about the freshness of the cached data (e.g., in a settings or status view).
    ///   - Indicate how many like/unlike actions will be synced when connectivity is available.
    ///   The values are derived from:
    ///   - `LocalStorageManager.getLastSyncDate()`
    ///   - `LocalStorageManager.getPendingLikes()`
    ///
    /// - Concurrency:
    ///   - Runs on the main actor (the enclosing type is annotated with `@MainActor`).
    ///   - Performs no asynchronous work.
    ///
    /// - Performance:
    ///   - Intended to be inexpensive and safe to call frequently (e.g., on view appear).
    ///
    /// - Side Effects:
    ///   - None. This is a pure read of cached metadata.
    ///
    /// - Example:
    ///   ```swift
    ///   let info = viewModel.getCacheInfo()
    ///   if let lastSync = info.lastSync {
    ///       print("Last synced at:", lastSync.formatted())
    ///   } else {
    ///       print("No previous sync recorded.")
    ///   }
    ///   print("Pending likes to sync:", info.pendingLikesCount)
    ///   ```
    ///
    /// - SeeAlso:
    ///   - ``clearCache()``
    ///   - ``loadFoods()``
    ///   - ``refreshFoods()``
    ///   - `LocalStorageManager.getLastSyncDate()`
    ///   - `LocalStorageManager.getPendingLikes()`
    func getCacheInfo() -> (lastSync: Date?, pendingLikesCount: Int) {
        let lastSync = localStorageManager.getLastSyncDate()
        let pendingLikes = localStorageManager.getPendingLikes()
        return (lastSync, pendingLikes.count)
    }
}
