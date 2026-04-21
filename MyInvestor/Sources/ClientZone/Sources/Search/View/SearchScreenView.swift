//
//  SearchScreenView.swift
//  MyInvestor
//
//  Created by Максим Скориков on 05.03.2026.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SearchScreenView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    var allSecurities: [PromotionItem]
    @Binding var favoriteSecIDs: [String]
    var onSelect: (PromotionItem) -> Void
    
    private let db = Firestore.firestore()
    
    private var filteredSecurities: [PromotionItem] {
        if searchText.isEmpty {
            return allSecurities
        }
        return allSecurities.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.symbol.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredSecurities) { item in
                            HStack {
                                Button {
                                    onSelect(item)
                                    dismiss()
                                } label: {
                                    PromotionCardView(item: item)
                                }
                                Spacer()
                                Button(action: {
                                    toggleFavorite(for: item.symbol)
                                }) {
                                    Image(systemName: favoriteSecIDs.contains(item.symbol) ? "star.fill" : "star")
                                        .foregroundColor(.orange)
                                        .padding(8)
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Все акции")
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .semibold))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .foregroundColor(.white)
            .background(Color(hex: "161514"))
        }
    }
    
    private func toggleFavorite(for symbol: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if favoriteSecIDs.contains(symbol) {
            db.collection("users").document(uid)
                .updateData(["favoriteStocks": FieldValue.arrayRemove([symbol])])
        } else {
            db.collection("users").document(uid)
                .updateData(["favoriteStocks": FieldValue.arrayUnion([symbol])])
        }
        
        if favoriteSecIDs.contains(symbol) {
            favoriteSecIDs.removeAll { $0 == symbol }
        } else {
            favoriteSecIDs.append(symbol)
        }
    }
}
