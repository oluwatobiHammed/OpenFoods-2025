//
// MulticolorGlow+Text.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//


import SwiftUI
// MARK: - View Extensions
extension Text {
    func multicolorGlow() -> some View {
        self
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue, .purple, .pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}
