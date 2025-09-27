//
//  FoodRowView.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//

import SwiftUI


struct FoodRowView: View {
    let food: Food
    @EnvironmentObject var viewModel: FoodListViewModel
    @State private var isPressed = false
    @State private var showingDetail = false
    @State var isLiked = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            HStack(spacing: 15) {
                AsyncImageView(urlString: food.photoURL)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(food.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(food.flagEmoji)
                            .font(.title2)
                    }
                    
                    Text(food.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text("\("updated".localized): \(food.formattedDate)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: { toggleLike() }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor( isLiked ? .red : .gray)
                                .font(.title3)
                                .scaleEffect(isPressed ? 1.3 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { 
            // Long press gesture handling
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
        .sheet(isPresented: $showingDetail) {
            FoodDetailView(food: food, dismissCallback: {
                isLiked = viewModel.foods.first(where: {$0.id == food.id})?.isLiked ?? false
            })
            .environmentObject(viewModel)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .onAppear(perform: {
            isLiked = viewModel.foods.first(where: {$0.id == food.id})?.isLiked ?? false
        })
        
    }
    
    private func toggleLike() {
        isPressed = true
        
        Task {
            await viewModel.toggleLike(for: food)
            isLiked = viewModel.foods.first(where: {$0.id == food.id})?.isLiked ?? false
        }
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPressed = false
        }
    }
}
