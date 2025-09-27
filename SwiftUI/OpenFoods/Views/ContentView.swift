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
    

    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                .ignoresSafeArea()
                    
                    FoodListView()
                        .environmentObject(viewModel)

            }
            .navigationTitle("app_title".localized)
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


