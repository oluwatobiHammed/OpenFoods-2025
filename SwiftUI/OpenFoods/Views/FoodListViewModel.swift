//
//  FoodListViewModel.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import Foundation



// MARK: - View Model
class FoodListViewModel: ObservableObject {
    @Published var foods: [Food] = []
    @Published var food: Food?
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasError = false
    @Published var errorMessage = ""
    
    private var networkManager: NetworkManager?
    private var currentPage = 0
    private var totalCount = 0
    private var canLoadMore = true
    
    
    func configure() {
        self.networkManager = NetworkManager()
        
        Task {
            await loadFoods()
        }
    }
    
    @MainActor
    func loadFoods() async {
        guard let networkManager = networkManager else { return }
        
        isLoading = true
        hasError = false
        currentPage = 0
        
        do {
            let response = try await networkManager.fetchFoods(page: currentPage)
            foods = response.foods
            totalCount = response.totalCount
            canLoadMore = foods.count < totalCount
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadMoreFoodsIfNeeded() async {
        guard let networkManager = networkManager,
              canLoadMore && !isLoadingMore && !isLoading else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        do {
            let response = try await networkManager.fetchFoods(page: currentPage)
            foods.append(contentsOf: response.foods)
            canLoadMore = foods.count < totalCount
        } catch {
            currentPage -= 1 // Reset page on error
            hasError = true
            errorMessage = error.localizedDescription
        }
        
        isLoadingMore = false
    }
    
    @MainActor
    func refreshFoods() async {
        await loadFoods()
    }
    
    @MainActor
    func toggleLike(for food: Food) async {
        guard let networkManager = networkManager,
              let index = foods.firstIndex(where: { $0.id == food.id }) else { return }
        
        do {
            let success = if food.isLiked {
                try await networkManager.unlikeFood(id: food.id)
            } else {
                try await networkManager.likeFood(id: food.id)
            }
            
            if success {
                foods[index].isLiked.toggle()
                // Note: In a real app, we might want to refresh the list to get updated lastUpdatedDate
            }
        } catch {
            hasError = true
            errorMessage = "Failed to update like status: \(error.localizedDescription)"
        }
    }
}
