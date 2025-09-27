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
    
    /// Loads an image asynchronously from the given URL string, updating the published
    /// `image` and `isLoading` properties, and caches successful results.
    ///
    /// This method:
    /// - Validates the `urlString` and returns immediately if it cannot be converted into a `URL`.
    /// - Checks an in-memory cache (`ImageCache.shared`) first; if a cached image is found, it assigns
    ///   it to `image` and returns without performing any network request.
    /// - Sets `isLoading` to `true` while a network request is in flight, and guarantees it returns to
    ///   `false` when the operation completes (using `defer`).
    /// - Fetches image data using `URLSession.shared.data(from:)`, converts it to a `UIImage` on success,
    ///   stores it back into the cache, and publishes it via `image`.
    /// - Prints an error message on failure and leaves the current `image` unchanged; it does not throw.
    ///
    /// Concurrency and threading:
    /// - Annotated with `@MainActor`, ensuring that state changes to published properties occur on the main thread.
    /// - Safe to call from any thread; the work that mutates `image`/`isLoading` is performed on the main actor.
    /// - The method is `async` and can be awaited from Swift concurrency contexts.
    ///
    /// Caching:
    /// - Uses `ImageCache.shared` keyed by the provided `urlString`.
    /// - If the image is already cached, no network request is performed.
    ///
    /// Cancellation and reentrancy:
    /// - The method does not explicitly check for `Task.isCancelled`; if a task is cancelled, any in-flight
    ///   network request may still complete and update `image`.
    /// - Multiple concurrent invocations may race; the last completed call wins and sets the final `image`.
    ///
    /// - Parameter urlString: The absolute or valid URL string pointing to the remote image resource.
    ///
    /// - SeeAlso: `ImageCache`
    ///
    /// - Example:
    /// ```swift
    /// @StateObject private var loader = AsyncImageLoader()
    ///
    /// var body: some View {
    ///     VStack {
    ///         if loader.isLoading {
    ///             ProgressView()
    ///         } else if let uiImage = loader.image {
    ///             Image(uiImage: uiImage)
    ///                 .resizable()
    ///                 .scaledToFit()
    ///         }
    ///     }
    ///     .task {
    ///         await loader.loadImage(from: model.thumbnailURL)
    ///     }
    /// }
    /// ```
    @MainActor
    func loadImage(from urlString: String) async {
        guard let url = URL(string: urlString) else { return }

        // Check cache first
        if let cachedImage = ImageCache.shared.get(forKey: urlString) {
            self.image = cachedImage
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                // Cache the image
                ImageCache.shared.set(uiImage, forKey: urlString)
                self.image = uiImage
            }
        } catch {
            // Handle error if needed
            print("❌ Failed to load image:", error)
        }
    }
}
