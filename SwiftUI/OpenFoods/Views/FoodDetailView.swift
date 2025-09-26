//
//  FoodDetailView.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import SwiftUI


/// FoodDetailView
///
/// A SwiftUI screen that presents rich details for a single `Food` item, including
/// a remote photo, localized name and flag, description, last-updated metadata,
/// and a Like/Unlike control. The content is scrollable and wrapped in a
/// navigation context with a trailing Done button for dismissal.
///
/// Requirements
/// - Expects a `Food` instance to render.
/// - Requires a `FoodListViewModel` injected via `@EnvironmentObject`. The view
///   reads from this model to determine the current like state and invokes it to
///   toggle likes. Not providing the environment object will result in a runtime crash.
///
/// Behavior
/// - Loads and displays `food.photoURL` asynchronously via `AsyncImageView`.
/// - Shows a fallback message when `food.description` is empty.
/// - On appear, initializes `isLiked` by reading the corresponding item from the
///   `viewModel.foods` collection (matched by `food.id`).
/// - Tapping the Like/Unlike button launches an asynchronous task that awaits
///   `viewModel.toggleLike(for:)`, then refreshes `isLiked` to reflect the model’s
///   latest state. The heart icon and label update immediately based on `isLiked`.
/// - Displays `food.formattedDate` under a “Last Updated” label.
/// - Tapping Done first executes `dismissCallback` (if provided) and then calls
///   the environment `dismiss` action to close the view.
///
/// Concurrency
/// - The like mutation runs inside a `Task` and awaits the view model’s async API.
///   UI state (`isLiked`) is updated on completion to keep the interface consistent
///   with the model.
///
/// Styling & Layout
/// - Uses `ScrollView` with vertical `VStack` layout and standard spacing.
/// - The hero image is clipped to a rounded rectangle and fixed at 250pt height.
/// - Employs system text styles (`.largeTitle`, `.headline`, `.body`, `.caption`,
///   `.footnote`) for Dynamic Type compatibility.
/// - Inline navigation bar title: “Food Details”.
///
/// Accessibility
/// - Relies on SF Symbols (`heart`, `heart.fill`) for the like icon.
/// - Text uses semantic styles to respect user font-size preferences.
///
/// Dismissal
/// - Uses `@Environment(\.dismiss)` to close the view.
/// - Optionally notifies callers via `dismissCallback` to coordinate external
///   side effects (e.g., analytics, state synchronization) before dismissal.
///
/// Dependencies
/// - `Food`: domain model expected to expose at least `id`, `name`, `description`,
///   `flagEmoji`, `photoURL`, `formattedDate`, and `isLiked`.
/// - `FoodListViewModel`: provides a `foods` collection and an async
///   `toggleLike(for:)` API.
/// - `AsyncImageView`: helper view to load and display remote images.
///
/// Properties
/// - food: The `Food` item whose details are presented.
/// - dismissCallback: Optional closure executed just before the view dismisses,
///   enabling callers to perform additional work.
/// - isLiked: Local UI state mirroring the food’s like status for immediate feedback
///   and button rendering.
/// - viewModel: Environment-injected `FoodListViewModel` used to read and mutate
///   like state across the foods list.
/// - dismiss: Environment dismiss action invoked by the Done button to close the view.
///
/// Body
/// - Composes the detail screen, including the asynchronous image, name and flag,
///   description, “Last Updated” section, and a Like/Unlike button that reflects
///   and mutates the model’s like state.
struct FoodDetailView: View {
    let food: Food
    var dismissCallback: (() -> Void)?
    @State var isLiked = false
    @EnvironmentObject var viewModel: FoodListViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    AsyncImageView(urlString: food.photoURL)
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(food.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text(food.flagEmoji)
                                .font(.title)
                        }
                        
                        Text("Description")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(food.description.isEmpty ? "No description available." : food.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Last Updated")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(food.formattedDate)
                                    .font(.footnote)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                Task {
                                    await viewModel.toggleLike(for: food)
                                    isLiked = viewModel.foods.first(where: {$0.id == food.id})?.isLiked ?? false
                                }
                            }) {
                                
                                HStack {
                                    Image(systemName: isLiked ? "heart.fill" : "heart")
                                    Text(isLiked ? "Unlike" : "Like")
                                }
                                .foregroundColor(isLiked ? .red : .blue)
                            }
                            .onAppear {
                                isLiked = viewModel.foods.first(where: {$0.id == food.id})?.isLiked ?? false
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Food Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismissCallback?()
                        dismiss()
                    }
                }
            }
        }
    }
}
