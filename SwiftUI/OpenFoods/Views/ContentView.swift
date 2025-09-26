//
//  ContentView.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import SwiftUI

// MARK: - Main ContentView

/// The root SwiftUI view for the application’s main screen.
///
/// ContentView is responsible for:
/// - Hosting the primary `FoodListView`.
/// - Providing and owning the lifecycle of a `FoodListViewModel` via `@StateObject`.
/// - Rendering a color-scheme–aware background gradient.
/// - Establishing navigation context (title and display mode).
/// - Kicking off asynchronous configuration work for the view model when the view appears.
///
/// This view adapts its appearance based on the current `colorScheme` and exposes
/// reusable gradients for background, titles, and buttons to help maintain a consistent
/// look and feel across the app.
///
/// Dependency Injection:
/// - A `FoodListViewModel` must be provided at initialization time. This allows you to
///   supply production or test doubles as appropriate for your environment.

/// The view model that powers the food list UI.
///
/// - Note: Marked as `@StateObject` so that `ContentView` owns the model’s lifecycle
///   and it persists across view updates. This prevents reinitialization during state
///   changes and ensures a single source of truth for the list state.

/// The current system color scheme from the SwiftUI environment.
///
/// Used to dynamically adjust gradients and other appearance-related elements so the UI
/// looks great in both Light and Dark modes.

/// A handle to any in-flight asynchronous work started by this view.
///
/// - Important: This is a convenience for managing and canceling ongoing tasks tied to
///   the view’s lifecycle (e.g., long-running loads). It is currently reserved for future
///   use; consider canceling the task in `onDisappear` or `deinit` if adopted.

/// Controls whether a settings interface is presented.
///
/// - Note: Currently reserved for future use. Toggle this state to present a settings
///   sheet or push a settings screen when implemented.

/// Creates a new `ContentView`.
///
/// - Parameter viewModel: A fully-configured `FoodListViewModel` that will be owned
///   by this view. Inject a real instance in production or a mock for previews/tests.
///
/// - Important: The view stores the `viewModel` as a `@StateObject`, transferring
///   ownership to the view so it survives SwiftUI updates and remains stable.

/// A color-scheme–aware background gradient.
///
/// - Light Mode: A blend of blue and purple with subtle opacity for depth.
/// - Dark Mode: A layered set of dark system grays for a subdued, contrast-friendly
///   backdrop.
///
/// Use this as the base background for the screen. It is applied edge-to-edge via
/// `.ignoresSafeArea()`.

/// A gradient intended for prominent titles or header accents.
///
/// - Light Mode: Blue → Purple → Pink
/// - Dark Mode: Cyan → Blue → Purple
///
/// - Note: Not currently applied within the view hierarchy, but provided for consistent
///   styling across title elements if needed.

/// A gradient intended for primary buttons and interactive elements.
///
/// - Light Mode: Blue → Purple
/// - Dark Mode: Cyan → Blue
///
/// - Note: Not currently applied within the view hierarchy, but available to ensure
///   consistent button styling across the app.

/// The primary view hierarchy.
///
/// Structure:
/// - `NavigationView` provides navigation context and a large title.
/// - `ZStack` layers the background gradient behind the content.
/// - `FoodListView` is injected with the shared `viewModel` via `environmentObject`.
///
/// Behavior:
/// - Sets the navigation title to “OpenFoods” with a large display mode.
/// - Triggers `await viewModel.configure()` using `.task` so any initial data loading
///   or setup occurs when the view appears.
///
/// - Accessibility: The color-scheme–aware gradients aim to preserve contrast while
///   maintaining visual appeal in both Light and Dark modes.
///
/// - Performance: Using `@StateObject` for the view model avoids redundant work due to
///   view refreshes and ensures stable state management across updates.
struct ContentView: View {
    @StateObject private var viewModel: FoodListViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var loadingTask: Task<Void, Never>?
    @State private var showingSettings = false
    
    init(viewModel: FoodListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private var backgroundGradient: LinearGradient {
        
        return LinearGradient(
            colors: colorScheme == .dark ? [
                Color.black,
                Color(.systemGray6),
                Color(.systemGray5)
            ] : [Color.blue.opacity(0.6),
                 Color.purple.opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
    }
    
    private var titleGradient: LinearGradient {
        return LinearGradient(
            colors: colorScheme == .dark ?
            [.cyan, .blue, .purple]
            : [.blue, .purple, .pink],
            startPoint: .leading,
            endPoint: .trailing
        )
        
    }
    
    private var buttonGradient: LinearGradient {
        return LinearGradient(
            colors: colorScheme == .dark ?
            [Color.cyan, Color.blue] :
                [Color.blue, Color.purple],
            startPoint: .leading,
            endPoint: .trailing
        )
        
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                .ignoresSafeArea()
                    
                    FoodListView()
                        .environmentObject(viewModel)

            }
            .navigationTitle("OpenFoods")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.configure()
            }
        }

    }
}
//#Preview {
//    ContentView()
//}


