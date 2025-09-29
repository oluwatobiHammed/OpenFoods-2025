//
//  FoodRowView.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import SwiftUI


/// A SwiftUI row view that displays a summary of a `Food` item, including its image,
/// name, country flag, brief description, last-updated date, and a like button.
/// 
/// The row supports:
/// - Tap to present a detail sheet (`FoodDetailView`) for the given `food`.
/// - Press feedback animations on both the row and the heart icon.
/// - Toggling a like state via a view model (`FoodListViewModel`) and keeping a local
///   `isLiked` cache in sync with the model.
///
/// - Requirements:
///   - An instance of `FoodListViewModel` must be injected into the environment using
///     `.environmentObject(...)`.
///   - The provided `Food` must exist in `viewModel.foods` for the local like state
///     to mirror accurately.
///
/// - Accessibility:
///   - Uses system text styles (`.headline`, `.caption`, `.caption2`) for Dynamic Type.
///   - Consider adding explicit `.accessibilityLabel` and `.accessibilityValue` modifiers
///     to the like button and image for improved VoiceOver support.
///
/// - SeeAlso:
///   - ``FoodListViewModel``
///   - ``FoodDetailView``
///   - ``AsyncImageView``
///
/// - Threading:
///   - The like toggle is performed in an async `Task`. If your view model is not
///     main-actor isolated, ensure SwiftUI state updates occur on the main actor.
///
/// - Styling:
///   - The row uses `.ultraThinMaterial` as a background and a subtle drop shadow.
///   - The heart icon uses a spring animation to scale on press.
///

/// The `Food` model that this row renders.

/// The list view model supplied via the environment, responsible for providing and mutating
/// the list of foods, including toggling the liked state.

/// Tracks whether the row or the heart icon is currently in a pressed (animated) state.
/// This drives the scale effect animations for press feedback.

/// Controls presentation of the `FoodDetailView` sheet when the row is tapped.

/// A local cache of the like state for the `food`. It mirrors `viewModel.foods` and is
/// refreshed on appear and when the detail sheet is dismissed. Falls back to `false` if
/// the `food` cannot be found in the model.
///
/// - Note: This local state is used to drive the heart icon immediately while the model
/// publishes its change; it should remain consistent with the source of truth in the view model.

/// The primary view hierarchy for the row.
/// 
/// - Layout:
///   - Leading: `AsyncImageView` thumbnail of the food.
///   - Center: Name + flag (top), description (middle), updated date + heart button (bottom).
///   - Trailing: Spacer for alignment.
///
/// - Gestures:
///   - The entire row is wrapped in a button to open the detail sheet.
///   - A zero-duration long-press gesture is used to track press state (`isPressed`) for
///     subtle scale animations on touch down/up.
///
/// - Animations:
///   - Row: `easeInOut` scaling when pressed.
///   - Heart: `spring` scaling when toggled.
///
/// - Navigation:
///   - Presents `FoodDetailView` via `.sheet(isPresented:)`.
///   - On dismissal, refreshes `isLiked` from the view model to ensure consistency.
///
/// - State Sync:
///   - On appear, synchronizes `isLiked` with the corresponding item in `viewModel.foods`.

/// Toggles the liked state for the current `food`.
///
/// This method:
/// 1. Starts a short press animation by setting `isPressed` to `true`.
/// 2. Launches an asynchronous task that calls `FoodListViewModel.toggleLike(for:)` to flip
///    the like/unlike state in the data model.
/// 3. After the model finishes updating, refreshes the local `isLiked` flag by reading the
///    updated item from `viewModel.foods`.
/// 4. Ends the press animation by resetting `isPressed` to `false` after a 0.3‑second delay,
///    which drives the heart icon scale animation.
///
/// - Important: Changes to `isPressed` and `isLiked` trigger SwiftUI view updates. Ensure
///   `FoodListViewModel.toggleLike(for:)` publishes changes so the lookup reflects the new state.
/// - Note: If the `food` cannot be found in `viewModel.foods`, `isLiked` falls back to `false`.
/// - Threading: The toggle runs inside a `Task`. If `FoodListViewModel` is not main‑actor isolated,
///   prefer updating SwiftUI state on the main actor to avoid concurrency warnings.
/// - SeeAlso: ``FoodListViewModel/toggleLike(for:)``
/// - Returns: Nothing.
struct FoodRowView: View {
    let food: Food
    @EnvironmentObject var viewModel: FoodListViewModel
    @State private var isPressed = false
    @State private var showingDetail = false
    @State var isLiked = false
    @State private var isSelected = false
    
    var body: some View {
        Button(action: {
            // Animate selection before navigation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isSelected = true
            }
            
            // Delay navigation slightly to show animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showingDetail = true
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isSelected = false
                }
            }
           
        }) {
            HStack(spacing: 15) {
                AsyncImageView(urlString: food.photoURL)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: isSelected ? .blue.opacity(0.5) : .clear, radius: 8, x: 0, y: 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(food.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(food.flagEmoji)
                            .font(.title2)
                            .scaleEffect(isSelected ? 1.2 : 1.0)
                    }
                    
                    Text(food.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text("\("updated".localized): \(food.formattedDate)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: { toggleLike() }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor( isLiked ? .red : .gray)
                                .font(.title3)
                                .scaleEffect(isPressed ? 1.3 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(isSelected ? 0.3 : 0.1), radius: isSelected ? 10 : 5, x: 0, y: isSelected ? 8 : 2)
                    .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                            .stroke(isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
                                    )
            )
            .scaleEffect(isSelected ? 1.05 : (isPressed ? 0.98 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { 
            // Long press gesture handling
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
        .sheet(isPresented: $showingDetail) {
            FoodDetailView(food: food, dismissCallback: {
                isLiked = viewModel.foods.first(where: {$0.id == food.id})?.isLiked ?? false
            })
            .environmentObject(viewModel)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .onAppear(perform: {
            isLiked = viewModel.foods.first(where: {$0.id == food.id})?.isLiked ?? false
        })
        
    }
    
    /// Toggles the liked state for the current `food`.
    ///
    /// This method:
    /// 1. Starts a short press animation by setting `isPressed` to `true`.
    /// 2. Launches an asynchronous task that calls `FoodListViewModel.toggleLike(for:)` to flip the like/unlike state in the data model.
    /// 3. After the model finishes updating, refreshes the local `isLiked` flag by reading the updated item from `viewModel.foods`.
    /// 4. Ends the press animation by resetting `isPressed` to `false` after a 0.3‑second delay, which drives the heart icon scale animation.
    ///
    /// - Important: Changes to `isPressed` and `isLiked` trigger SwiftUI view updates. Ensure `FoodListViewModel.toggleLike(for:)` publishes changes so the lookup reflects the new state.
    /// - Note: If the `food` cannot be found in `viewModel.foods`, `isLiked` falls back to `false`.
    /// - Threading: The toggle runs inside a `Task`. If `FoodListViewModel` is not main‑actor isolated, prefer updating SwiftUI state on the main actor to avoid concurrency warnings.
    /// - SeeAlso: ``FoodListViewModel/toggleLike(for:)``
    /// - Returns: Nothing.
    private func toggleLike() {
        isPressed = true
        
        Task {
            await viewModel.toggleLike(for: food)
            isLiked = viewModel.foods.first(where: {$0.id == food.id})?.isLiked ?? false
        }
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPressed = false
        }
    }
}
