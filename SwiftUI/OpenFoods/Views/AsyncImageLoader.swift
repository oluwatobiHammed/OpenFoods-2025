//
//  AsyncImageLoader.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import Foundation
import SwiftUI


// MARK: - Async Image Loader
class AsyncImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        // Check cache first
        if let cachedImage = ImageCache.shared.get(forKey: urlString) {
            self.image = cachedImage
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                guard let data = data,
                      let uiImage = UIImage(data: data),
                      error == nil else {
                    return
                }
                
                // Cache the image
                ImageCache.shared.set(uiImage, forKey: urlString)
                self?.image = uiImage
            }
        }.resume()
    }
}