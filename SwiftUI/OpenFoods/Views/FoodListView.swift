//
//  FoodListView.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import SwiftUI


struct FoodListView: View {
    @EnvironmentObject var viewModel: FoodListViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading && viewModel.foods.isEmpty {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text("Loading delicious foods...")
                        .foregroundColor(.white)
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.hasError {
                ErrorView(error: viewModel.errorMessage) {
                    Task {
                        await viewModel.loadFoods()
                    }
                }
            } else {
                List {
                    ForEach(viewModel.foods, id: \.id) { food in
                        FoodRowView(food: food)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .onAppear {
                                if food.id == viewModel.foods.last?.id {
                                    Task {
                                        await viewModel.loadMoreFoodsIfNeeded()
                                    }
                                }
                            }
                    }
                    
                    if viewModel.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading more...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    await viewModel.refreshFoods()
                }
            }
        }
        .task {
            if viewModel.foods.isEmpty {
                await viewModel.loadFoods()
            }
        }
    }
}
