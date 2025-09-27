//
//  AsyncImageView.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import SwiftUI


/// A lightweight SwiftUI view that asynchronously loads and displays an image
/// from a remote URL string using Swift Concurrency.
///
/// Overview
/// - Displays the fetched image with `aspectRatio(.fill)` when available.
/// - Shows a `ProgressView` while the image is being fetched.
/// - Falls back to a placeholder SF Symbol (`photo`) if loading fails or no image is available.
/// - Uses `@StateObject` to keep the loader alive across view updates and avoid repeated fetches.
///
/// Requirements
/// - Platforms: iOS 15+, iPadOS 15+, macOS 12+, tvOS 15+, watchOS 8+ (uses `.task`).
/// - Relies on an `AsyncImageLoader` type that exposes:
///   - `image: UIImage?` (or platform-appropriate image type)
///   - `isLoading: Bool`
///   - `func loadImage(from: String) async`
///
/// Behavior
/// - On appearance, starts loading via `.task { await loader.loadImage(from: urlString) }`.
/// - While `loader.isLoading == true`, a `ProgressView` is shown over a light gray background.
/// - When `loader.image` becomes non-nil, the image is rendered as resizable with aspect fill.
/// - If loading fails or no image is set, a gray `photo` placeholder is shown.
///
/// Important
/// - The view uses `.aspectRatio(contentMode: .fill)`, which may crop content to fill its container.
///   If you need to fit without cropping, adjust the content mode where this view is used.
/// - If `urlString` can change over the lifetime of the same view identity, consider attaching
///   the task with an identity, e.g. `.task(id: urlString)`, to ensure reloading on URL changes.
/// - Ensure `AsyncImageLoader` performs decoding and caching appropriately (if desired) and updates
///   its published properties on the main actor.
///
/// Accessibility
/// - Consider adding an `.accessibilityLabel` where this view is used to describe the image content,
///   or provide a descriptive label for the placeholder state.
///
/// Parameters
/// - urlString: The absolute URL string of the image to fetch. Invalid or unreachable URLs will
///   result in the placeholder being displayed.
///
/// Example
/// ```swift
/// // In a parent view:
/// AsyncImageView(urlString: "https://example.com/image.jpg")
///     .frame(width: 120, height: 120)
///     .clipped() // Optional: to constrain aspect fill cropping to the frame
///     .accessibilityLabel("Product photo")
/// ```
///
/// See Also
/// - `AsyncImageLoader`: Responsible for performing the actual fetch and exposing loading state.
/// - `SwiftUI.AsyncImage`: Apple’s built-in alternative; this view is a custom, more controllable variant.
///
///
/// Property: urlString
/// The absolute URL string pointing to the image resource to load. If the string cannot be
/// converted to a valid URL or the request fails, the view shows the placeholder.
///
///
/// Property: loader
/// A `@StateObject` that owns the asynchronous loading lifecycle. It provides:
/// - `image`: The downloaded image when available.
/// - `isLoading`: Whether a fetch operation is currently in progress.
/// Using `@StateObject` ensures the loader instance persists across re-renders for the same view identity.
///
///
/// Body
/// A `ZStack` that conditionally presents:
/// - The loaded image (resizable, aspect fill).
/// - A progress indicator with a subtle gray background while loading.
/// - A gray `photo` SF Symbol placeholder when no image is available.
struct AsyncImageView: View {
    let urlString: String
    @StateObject private var loader = AsyncImageLoader()
    
    var body: some View {
        ZStack {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if loader.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.2))
            } else {
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.2))
            }
        }
        .task {
            await loader.loadImage(from: urlString)
        }
    }
}
