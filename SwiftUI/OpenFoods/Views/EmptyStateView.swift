//
//  EmptyStateView.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import SwiftUI

// MARK: - Empty State View
/// A reusable SwiftUI view that communicates the “empty state” of a picture
/// collection and encourages the user to fetch their first item.
///
/// ## Overview
/// `EmptyStateView` presents:
/// - A decorative gradient circle containing the SF Symbol `photo.stack`.
/// - A title (“No Pictures Yet”) and a short, friendly description that
///   explains what to do next.
///
/// The view adapts its colors automatically to the current system appearance
/// (light or dark mode) using the `colorScheme` environment value.
///
/// ## Layout
/// - Vertical stack with comfortable spacing
///   - ZStack:
///     - Gradient-filled circle (120×120)
///     - Large “photo.stack” symbol centered inside
///   - Vertical stack of text:
///     - Title: “No Pictures Yet” (semibold, title2)
///     - Description: guidance text, multiline and centered
/// - Overall padding for breathing room
///
/// ## Appearance & Theming
/// - Uses a linear gradient (blue → purple) with opacity that varies by
///   color scheme to maintain contrast in both light and dark modes.
/// - Text and symbol colors are chosen to remain legible across appearances:
///   - Title contrasts the background (black in light mode, white in dark mode).
///   - Secondary description text dims slightly (secondary/gray) to reduce
///     visual noise while staying readable.
///
/// ## Environment
/// - `colorScheme`: Read from the environment to adjust gradient opacity and
///   foreground colors for light and dark modes.
///
/// ## Accessibility
/// - The decorative symbol should ideally be marked as decorative (e.g.,
///   hidden from accessibility) to avoid redundant announcements with the
///   explanatory text. If you need more explicit guidance for assistive
///   technologies, consider providing an accessibility label or combining
///   elements into a single accessible element.
/// - Text is large enough and uses system fonts, benefiting from Dynamic Type.
///
/// ## Localization
/// - Localize the strings:
///   - "No Pictures Yet"
///   - "Tap the button above to fetch your first picture and start building your collection!"
///
/// ## Usage
/// Display `EmptyStateView` when the picture data source is empty, such as:
/// - Initial app launch before any content has been fetched
/// - After clearing a collection or encountering an empty filter result
///
/// ## Dependencies
/// - SwiftUI
///
/// ## Notes
/// - This view is purely presentational and has no side effects or user
///   interactions. It relies on a parent view to provide actions (e.g., a
///   button) that fetch or add content.
struct EmptyStateView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [
                            Color.blue.opacity(colorScheme == .dark ? 0.4 : 0.2),
                            Color.purple.opacity(colorScheme == .dark ? 0.4 : 0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "photo.stack")
                    .font(.system(size: 50))
                    .foregroundColor(colorScheme == .dark ? .white : .gray)
            }
            
            VStack(spacing: 8) {
                Text("No Pictures Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("Tap the button above to fetch your first picture and start building your collection!")
                    .font(.body)
                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding()
    }
}
