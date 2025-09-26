//
//  FoodDetailView.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import SwiftUI


struct FoodDetailView: View {
    let food: Food
    var dismissCallback: (() -> Void)?
    @State var isLiked = false
    @EnvironmentObject var viewModel: FoodListViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    AsyncImageView(urlString: food.photoURL)
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(food.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text(food.flagEmoji)
                                .font(.title)
                        }
                        
                        Text("Description")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(food.description.isEmpty ? "No description available." : food.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Last Updated")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(food.formattedDate)
                                    .font(.footnote)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                Task {
                                    await viewModel.toggleLike(for: food)
                                    isLiked = viewModel.foods.first(where: {$0.id == food.id})?.isLiked ?? false
                                }
                            }) {
                                
                                HStack {
                                    Image(systemName: isLiked ? "heart.fill" : "heart")
                                    Text(isLiked ? "Unlike" : "Like")
                                }
                                .foregroundColor(isLiked ? .red : .blue)
                            }
                            .onAppear {
                                isLiked = viewModel.foods.first(where: {$0.id == food.id})?.isLiked ?? false
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Food Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismissCallback?()
                        dismiss()
                    }
                }
            }
        }
    }
}
