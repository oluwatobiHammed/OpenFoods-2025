//
//  PrimaryButtonStyle.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import SwiftUI


// MARK: - Button Style
/// A reusable SwiftUI `ButtonStyle` that renders a prominent primary button.
///
/// Appearance:
/// - Adds standard padding around the button label.
/// - Applies a solid `Color.blue` background with a `.white` foreground color
///   for text and symbols.
/// - Clips the content to a `RoundedRectangle` with a 12pt corner radius,
///   producing a pill-like shape with subtle rounding.
/// - Provides pressed-state feedback by scaling the button down to 95% of its size,
///   animated with an ease-in-out curve over 0.1 seconds.
///
/// Interaction:
/// - The style reacts to `configuration.isPressed` to animate a brief scale effect,
///   giving tactile feedback without changing layout.
///
/// Usage:
/// ```swift
/// Button("Continue") { /* action */ }
///     .buttonStyle(PrimaryButtonStyle())
/// ```
///
/// Notes:
/// - The background color is fixed to `Color.blue`. For theming or dynamic colors,
///   consider introducing an initializer that accepts a color or reading from the
///   environment (e.g., app theme or accent color).
/// - Because the style clips to a rounded rectangle, any shadow or overlay should
///   be applied after the style on the button view if needed.
///
/// Accessibility:
/// - The default white-on-blue palette offers strong contrast. If you customize
///   colors, verify contrast ratios to maintain readability.
///
/// See also:
/// - `ButtonStyle`
/// - `ButtonStyleConfiguration`
/// - `View.buttonStyle(_:)`
///
/// Creates the view representing the body of a button using the provided configuration.
/// - Parameter configuration: The current button configuration supplied by SwiftUI,
///   containing the button’s label view and its pressed state (`isPressed`).
/// - Returns: A view that styles the label with padding, a blue background, white
///   foreground color, rounded clipping, and a short pressed-state scale animation.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
