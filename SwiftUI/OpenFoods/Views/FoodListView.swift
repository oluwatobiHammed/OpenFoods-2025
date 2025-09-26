//
//  FoodListView.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import SwiftUI


/// A SwiftUI view that displays a list of foods with support for loading, error handling,
/// infinite scrolling (pagination), and pull-to-refresh.
///
/// FoodListView observes a `FoodListViewModel` provided via the environment and renders
/// one of three primary states:
/// - Loading: Shows a progress indicator and a loading message when the initial fetch is in progress
///   and there are currently no foods to display.
/// - Error: Presents an `ErrorView` with a retry action if the view model reports an error.
/// - Content: Renders a `List` of `FoodRowView` items and handles pagination and refresh.
///
/// Behavior and features:
/// - Uses Swift Concurrency (`Task`/`async`) to trigger data loading on appearance and during pagination.
/// - Triggers the initial load in a `.task` modifier if the list is empty.
/// - Supports pull-to-refresh via `.refreshable`, delegating to `viewModel.refreshFoods()`.
/// - Implements infinite scrolling by detecting the appearance of the last row and calling
///   `viewModel.loadMoreFoodsIfNeeded()`.
/// - Shows a compact loading indicator row at the bottom of the list while more items are being fetched.
/// - Applies a plain list style and hides row separators for a cleaner, card-like appearance.
///
/// Dependencies/Expectations:
/// - An instance of `FoodListViewModel` must be injected into the environment (e.g., via `.environmentObject(_)`).
/// - `FoodRowView` is used to render individual food items.
/// - `ErrorView` is used to present errors and provide a retry mechanism.
/// - User-facing strings like "Loading delicious foods..." and "Loading more..." should be localized as needed.
///
/// Accessibility:
/// - Uses system `ProgressView` and `Text` to benefit from Dynamic Type and VoiceOver.
/// - The list structure preserves standard list semantics for assistive technologies.
///
/// Performance considerations:
/// - Pagination is driven by the appearance of the last visible item to minimize unnecessary fetches.
/// - Loading indicators are lightweight and only shown when needed.
///
/// - Note: Ensure `FoodListViewModel` is marked as an `ObservableObject` and is available in the environment
///   before presenting `FoodListView`. Missing the environment object will cause a runtime crash.
///
/// - SeeAlso: `FoodListViewModel`, `FoodRowView`, `ErrorView`
///
///
/// The view model backing this view, supplied via the environment.
/// Exposes loading, error, and data states, as well as actions to load, refresh,
/// and paginate the list.
///
/// The main content of the view.
/// Renders one of: a loading indicator, an error state with retry, or the list of foods.
/// Includes pull-to-refresh, infinite scrolling, and an initial-load `.task` hook.
struct FoodListView: View {
    @EnvironmentObject var viewModel: FoodListViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading && viewModel.foods.isEmpty {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text("Loading delicious foods...")
                        .foregroundColor(.white)
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.hasError {
                ErrorView(error: viewModel.errorMessage) {
                    Task {
                        await viewModel.loadFoods()
                    }
                }
            } else {
                List {
                    ForEach(viewModel.foods, id: \.id) { food in
                        FoodRowView(food: food)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .onAppear {
                                if food.id == viewModel.foods.last?.id {
                                    Task {
                                        await viewModel.loadMoreFoodsIfNeeded()
                                    }
                                }
                            }
                    }
                    
                    if viewModel.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading more...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    await viewModel.refreshFoods()
                }
            }
        }
        .task {
            if viewModel.foods.isEmpty {
                await viewModel.loadFoods()
            }
        }
    }
}
