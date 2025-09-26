//
//  PicturesViewModel.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

// MARK: - ViewModel
import SwiftUI

@MainActor
class PicturesViewModel: ObservableObject {
    @Published var foods: [Food] = []
//    @Published var addFood: [Food] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isRefreshing = false
    @Published var counter = 0
    
    private let networkManager: NetworkManagerProtocol
    private let userDefaults = UserDefaults.standard
    private let picturesKey = "savedPictures"
    private let picturesCounterKey = "savedPicturesCounter"
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
        loadSavedFood()
    }
    
    func fetchAndSaveFoods() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedFoods = try await networkManager.fetchFoods(page: 0).foods

            if fetchedFoods.isEmpty {
                foods.removeAll()
            } else {
                var updatedFoods = foods
                for newPicture in fetchedFoods {
                    if !updatedFoods.contains(where: { $0.id == newPicture.id }) {
                        updatedFoods.insert(newPicture, at: 0)
                    }
                }
                foods = updatedFoods
            }

           
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading pictures: \(error)")
        }
        //savePictures()
        isLoading = false
    }
    
//    func addNewFoods() {
//        
//        let startingCounter = counter
//        
//        // Keep searching until we find a unique picture or reach the end
//        while counter < foods.count {
//            let currentFood = foods[counter]
//            
//            // Check if picture already exists
//            if addFood.contains(where: { $0.id == currentFood.id }) {
//                counter += 1 // Skip this one
//                continue
//            }
//            
//            // Found a unique picture - add it
//            let insertionIndex = min(startingCounter, addFood.count)
//            addFood.insert(currentFood, at: insertionIndex)
//            
//            counter += 1
//            savePictures()
//            
//            return // Exit after adding one picture
//        }
//        print(counter)
//        print("No more unique pictures to add")
//   
//    }
    
    func deletePicture(at offsets: IndexSet) {
        counter -= 1
        print(counter)
        foods.remove(atOffsets: offsets)
        savePictures()
    }
    
    func deletePicture(withId id: Int) {
        counter -= 1
        foods.removeAll { $0.id == id }
        savePictures()
    }
    
    func movePicture(from source: Int, to destination: Int) {

        guard source != destination,
              foods.indices.contains(source),
              (0...foods.count).contains(destination) else {
            return
        }
        
        let item = foods.remove(at: source)
        foods.insert(item, at: destination)
        savePictures()
    }
    
    private func savePictures() {
        if let encoded = try? JSONEncoder().encode(foods) {
            userDefaults.set(encoded, forKey: picturesKey)
        }
        
        userDefaults.set(counter, forKey: picturesCounterKey)
    }
    
    private func loadSavedFood() {
        if let data = userDefaults.data(forKey: picturesKey),
           let decoded = try? JSONDecoder().decode([Food].self, from: data) {
            foods = decoded
        }
        
        counter = userDefaults.integer(forKey: picturesCounterKey)
    }
    
    func refreshPictures() async {
        isRefreshing = true
        await fetchAndSaveFoods()
        isRefreshing = false
    }
}
