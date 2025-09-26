//
//  ErrorView.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import SwiftUI


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
