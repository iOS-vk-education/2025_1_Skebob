//
//  PromotionScreenView.swift
//  MyInvestor
//
//  Created by Максим Скориков on 22.12.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct PromotionScreenView: View {
    
    let item: PromotionItem
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    // UI states
    @State private var shareCount: Int = 1
    @State private var isFav: Bool = false
    @State private var favoriteSecIDs: [String] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var currentBalance: Double = 100_000.0

    private let db = Firestore.firestore()

    var body: some View {
        VStack {
            // Цена и изменение
            VStack(spacing: 16) {
                Text(item.formattedPrice)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                Text(item.formattedChange)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(item.changeColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 16)

            // График
            ChartView(ticker: item.symbol)

            HStack {
                Text("Количество:")
                    .foregroundColor(.white)
                Spacer()
                Stepper(
                    "\(shareCount)",
                    value: $shareCount,
                    in: 1...10_000
                )
                .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            HStack {
                buyButton
                sellButton
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "161514").ignoresSafeArea())
        .safeAreaInset(edge: .top) {
            topBar
        }
        .alert("Операция", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            loadUserData()
        }
    }

    // MARK: - UI Components

    private var topBar: some View {
        HStack(spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image("BackIcon")
                    .topBarButtonStyle()
            }
            .padding(.leading, 16)
            
            Spacer()
            
            Text(item.name)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                toggleFavorite()
            } label: {
                Image("StarIcon")
                    .topBarButtonStyle(color: isFav ? SKBColor.coolYellowColor.suiColor : .white.opacity(0.4))
            }
            .padding(.trailing, 16)
        }
        .overlay(
            Circle()
                .fill(SKBColor.ambientAppColor_1.suiColor.opacity(0.1))
                .frame(width: 278, height: 278)
                .blur(radius: 200)
                .offset(y: -120)
                .overlay(
                    Circle()
                        .fill(SKBColor.ambientAppColor_2.suiColor.opacity(0.2))
                        .frame(width: 167, height: 167)
                        .blur(radius: 100)
                        .offset(y: -100)
                )
        )
    }

    private var buyButton: some View {
        Button {
            authViewModel.buyStock(
                symbol: item.symbol,
                shares: shareCount,
                price: item.price
            ) { success, message in
                DispatchQueue.main.async {
                    if success {
                        alertMessage = "Куплено \(shareCount) шт. \(item.symbol)"
                    } else {
                        alertMessage = message ?? "Ошибка покупки"
                    }
                    showingAlert = true
                }
            }
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(SKBColor.coolGreenColor.suiColor)
                .frame(width: 163, height: 48)
                .overlay(
                    Text("Купить")
                        .foregroundColor(.white)
                )
        }
        .disabled(Double(shareCount) * item.price > currentBalance)
    }

    private var sellButton: some View {
        Button {
            authViewModel.sellStock(
                symbol: item.symbol,
                shares: shareCount,
                price: item.price
            ) { success, message in
                DispatchQueue.main.async {
                    if success {
                        alertMessage = "Продано \(shareCount) шт. \(item.symbol)"
                    } else {
                        alertMessage = message ?? "Ошибка продажи"
                    }
                    showingAlert = true
                }
            }
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(SKBColor.coolRedColor.suiColor)
                .frame(width: 163, height: 48)
                .overlay(
                    Text("Продать")
                        .foregroundColor(.white)
                )
        }
    }

    // MARK: - Data Loading

    private func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    return
                }
                guard let data = snapshot?.data() else { return }

                DispatchQueue.main.async {
                    self.currentBalance = (data["balance"] as? Double) ?? 100_000.0

                    // Избранное
                    self.favoriteSecIDs = (data["favoriteStocks"] as? [String]) ?? []
                    self.isFav = self.favoriteSecIDs.contains(self.item.symbol)
                }
            }
    }

    private func toggleFavorite() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if isFav {
            db.collection("users").document(uid)
                .updateData(["favoriteStocks": FieldValue.arrayRemove([item.symbol])])
        } else {
            db.collection("users").document(uid)
                .updateData(["favoriteStocks": FieldValue.arrayUnion([item.symbol])])
        }
        
        isFav.toggle()
    }
}

#Preview {
    
    let testItem = PromotionItem(
            symbol: "SBER",
            name: "Сбербанк",
            price: 300.50,
            changePercent: 1.25,
            icon: "BTCIcon"
        )
    PromotionScreenView(item: testItem)
}
