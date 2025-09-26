//
//  ContentView.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import SwiftUI

// MARK: - Main ContentView

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
            .onAppear{
                viewModel.configure()
            }
        }

    }
}
//#Preview {
//    ContentView()
//}
//extension Text {
//    func multicolorGlow() -> some View {
//        self
//            .foregroundStyle(
//                LinearGradient(
//                    colors: [.blue, .purple, .pink],
//                    startPoint: .leading,
//                    endPoint: .trailing
//                )
//            )
//    }
//}

