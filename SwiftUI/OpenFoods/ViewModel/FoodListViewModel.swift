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
   
    
    func configure() async {
        
        await loadFoods()
    }
    
 
    private func loadCachedFoods() {
        let cachedFoods = localStorageManager.loadFoods()
        if !cachedFoods.isEmpty {
            foods = cachedFoods
            applyPendingLikes()
        }
    }
    
    
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
    
    
  
    private func applyPendingLikes() {
        let pendingLikes = localStorageManager.getPendingLikes()
        
        for (foodIdString, isLiked) in pendingLikes {
            if let foodId = Int(foodIdString),
               let index = foods.firstIndex(where: { $0.id == foodId }) {
                foods[index].isLiked = isLiked
            }
        }
    }
    
    
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
                 errorMessage = "no_internet".localized
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
    
   
    func refreshFoods() async {
        await loadFoods()
    }
    
    
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
    
    func clearCache() {
        localStorageManager.clearAllData()
        foods = []
        currentPage = 0
        totalCount = 0
        canLoadMore = true
    }
    
    func getCacheInfo() -> (lastSync: Date?, pendingLikesCount: Int) {
        let lastSync = localStorageManager.getLastSyncDate()
        let pendingLikes = localStorageManager.getPendingLikes()
        return (lastSync, pendingLikes.count)
    }
}
