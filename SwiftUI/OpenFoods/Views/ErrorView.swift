//
//  ErrorView.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import SwiftUI


/// A full-screen SwiftUI view that communicates an error state and offers a retry action.
/// 
/// This view presents:
/// - A prominent system warning icon
/// - A bold title indicating a failure
/// - A user-provided, human-readable error message
/// - A primary “Try Again” button that triggers a caller-supplied action
///
/// The layout is designed to expand and center its contents while filling all available space,
/// making it suitable for empty/error states or as an overlay in a `ZStack`.
///
/// - Parameters:
///   - error: A user-facing, localized description of the failure to display beneath the title.
///   - retry: A closure invoked when the user taps the “Try Again” button.
/// 
/// - Styling:
///   - Uses white typography and a red warning symbol. Provide a sufficiently contrasting background behind this view
///     for accessibility (e.g., a dark or tinted background).
///   - The button uses `PrimaryButtonStyle`, which must be available in your project. You can replace it with any
///     custom or system button style if desired.
/// 
/// - Accessibility:
///   - The large symbol and text support Dynamic Type. Consider adding additional accessibility modifiers in the
///     surrounding context if you need custom labels or traits.
///   - Ensure the `error` string is concise and user-friendly; avoid leaking technical details.
/// 
/// - Important:
///   If `retry` performs asynchronous work, wrap it in a `Task { ... }` to avoid blocking the main thread,
///   or provide an `async`-aware adapter at the call site.
/// 
/// - Example:
///   ```swift
///   ZStack {
///       Color.black.ignoresSafeArea()
///       ErrorView(error: viewModel.errorMessage) {
///           Task { await viewModel.reload() }
///       }
///   }
///   ```

/// The user-facing, localized description of the error to display.

/// Action executed when the user taps the “Try Again” button. Keep side effects minimal and consider dispatching
/// asynchronous work using `Task` if needed.

/// The view hierarchy that composes the error presentation (icon, title, message, and retry button).
struct ErrorView: View {
    let error: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Oops! Something went wrong")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(error)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again", action: retry)
                .buttonStyle(PrimaryButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
