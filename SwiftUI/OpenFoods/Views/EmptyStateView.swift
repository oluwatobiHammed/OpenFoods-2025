//
//  EmptyStateView.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import SwiftUI

// MARK: - Empty State View
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
