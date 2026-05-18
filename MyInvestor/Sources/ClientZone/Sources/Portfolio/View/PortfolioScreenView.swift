//
//  PortfolioScreenView.swift
//  MyInvestor
//
//  Created by Максим Скориков on 23.12.2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore


struct PortfolioStock: Identifiable, Equatable {
    let id = UUID()
    let symbol: String
    let shares: Int
    let avgBuyPrice: Double
    let currentPrice: Double
    
    var totalInvested: Double { Double(shares) * avgBuyPrice }
    var currentValue: Double { Double(shares) * currentPrice }
    var profitLoss: Double { currentValue - totalInvested }
    var profitLossPercent: Double {
        avgBuyPrice != 0 ? (profitLoss / totalInvested) * 100 : 0
    }
    
    var profitColor: Color {
        profitLoss >= 0 ? .green : .red
    }
}


struct PortfolioScreenView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var portfolioStocks: [PortfolioStock] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color(hex: "161514").ignoresSafeArea()
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 1.0, green: 0.5, blue: 0.0)))
                    .scaleEffect(1.5)
            } else if portfolioStocks.isEmpty {
                contentForEmptyPortfolio
            } else {
                ScrollView {
                    VStack(spacing: 30) {
                        totalPortfolioSummary

                        ForEach(portfolioStocks) { stock in
                            PortfolioStockCard(stock: stock)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 80)
                }
            }

            if let errorMessage = errorMessage {
                VStack {
                    Spacer()
                    ErrorMessageView(message: errorMessage)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            }
        }
        .task {
            await loadPortfolioAndPrices()
        }
    }

    private var contentForEmptyPortfolio: some View {
        VStack(spacing: 30) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.white.opacity(0.5))
            
            Text("Ваш портфель пуст")
                .font(.title2)
                .foregroundColor(.white)
                .fontWeight(.medium)
            
            Text("Купите первые акции, чтобы начать инвестировать")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var totalPortfolioSummary: some View {
        let totalValue = portfolioStocks.reduce(0) { $0 + $1.currentValue }
        let totalProfit = portfolioStocks.reduce(0) { $0 + $1.profitLoss }
        let totalProfitPercent = totalValue > 0 ? (totalProfit / (totalValue - totalProfit)) * 100 : 0

        return VStack(alignment: .leading, spacing: 8) {
            Text("Общая стоимость")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                Text("\(totalValue, specifier: "%.2f") ₽")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(totalProfit >= 0 ? "+" : "")
                        .foregroundColor(totalProfit >= 0 ? .green : .red)
                        + Text("\(totalProfit, specifier: "%.2f") ₽")
                        .font(.subheadline)
                        .foregroundColor(totalProfit >= 0 ? .green : .red)
                    
                    Text(totalProfit >= 0 ? "+" : "")
                        .foregroundColor(totalProfit >= 0 ? .green : .red)
                        + Text("\(totalProfitPercent, specifier: "%.2f")%")
                        .font(.caption)
                        .foregroundColor(totalProfit >= 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.16))
        )
        .padding(.horizontal, 20)
    }

    private func loadPortfolioAndPrices() async {
        isLoading = true
        errorMessage = nil

        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "Пользователь не авторизован"
            isLoading = false
            return
        }

        do {
            let db = Firestore.firestore()
            let snapshot = try await db.collection("users").document(uid).getDocument()

            guard let data = snapshot.data(),
                  let portfolio = data["portfolio"] as? [String: Any],
                  !portfolio.isEmpty else {
                portfolioStocks = []
                isLoading = false
                return
            }

            let securities = try await Security.fetchSecurityAsync()
            let securityMap = Dictionary(securities.map { ($0.secid, $0) }, uniquingKeysWith: { first, _ in first })

            var stocks: [PortfolioStock] = []
            for (symbol, stockData) in portfolio {
                guard let stockDict = stockData as? [String: Any],
                      let shares = stockDict["shares"] as? Int,
                      let avgPrice = stockDict["avgPrice"] as? Double else {
                    continue
                }

                let currentPrice = securityMap[symbol]?.price ?? avgPrice
                stocks.append(PortfolioStock(
                    symbol: symbol,
                    shares: shares,
                    avgBuyPrice: avgPrice,
                    currentPrice: currentPrice
                ))
            }

            portfolioStocks = stocks.sorted { $0.profitLoss > $1.profitLoss }
            isLoading = false

        } catch {
            errorMessage = "Не удалось загрузить данные"
            isLoading = false
        }
    }
}

struct PortfolioStockCard: View {
    let stock: PortfolioStock

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(stock.symbol)
                    .font(.headline)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)

                Text("\(stock.shares) акций")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("Средняя цена закупки: \(stock.avgBuyPrice, specifier: "%.2f") ₽")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("\(stock.currentValue, specifier: "%.2f") ₽")
                    .font(.headline)
                    .foregroundColor(.white)

                Text(stock.profitLoss >= 0 ? "+" : "")
                    .foregroundColor(stock.profitColor)
                    + Text("\(stock.profitLoss, specifier: "%.2f") ₽")
                    .font(.subheadline)
                    .foregroundColor(stock.profitColor)

                Text(stock.profitLoss >= 0 ? "+" : "")
                    .foregroundColor(stock.profitColor)
                    + Text("\(stock.profitLossPercent, specifier: "%.2f")%")
                    .font(.subheadline)
                    .foregroundColor(stock.profitColor)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.16))
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.5, blue: 0.0),
                            Color(red: 0.9, green: 0.3, blue: 0.1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: stock.profitLoss >= 0 ? 1.5 : 0
                )
                .opacity(stock.profitLoss >= 0 ? 1 : 0)
        )
    }
}

#Preview {
    PortfolioScreenView()
}
