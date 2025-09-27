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
            
            // Offline indicator
                  if viewModel.isOfflineMode {
                      HStack {
                          Image(systemName: "wifi.slash")
                          Text("offline_mode".localized)
                          Spacer()
                          let (_, pendingCount) = viewModel.getCacheInfo()
                          if pendingCount > 0 {
                              Text("\(pendingCount) \("pending".localized)")
                                  .font(.caption)
                                  .foregroundColor(.orange)
                          }
                      }
                      .padding(.horizontal)
                      .padding(.vertical, 8)
                      .background(Color.orange.opacity(0.2))
                      .foregroundColor(.orange)
                  }
            if viewModel.isLoading && viewModel.foods.isEmpty {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text("loading_foods".localized)
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
                            Text("loading_more".localized)
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
