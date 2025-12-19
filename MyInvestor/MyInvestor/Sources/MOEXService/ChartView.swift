//
//  ChartView.swift
//  MyInvestor
//
//  Created by Максим Скориков on 18.12.2025.
//

import SwiftUI
import Charts
import Foundation

struct ChartView: View {
    
    @State private var candles: [Candle] = []
    @State private var isLoading = false

    var body: some View {
        let prices = candles.map { $0.close }
        let minPrice = prices.min() ?? 0
        let maxPrice = prices.max() ?? 1
        let range = maxPrice - minPrice

        let padding: Double
        if range == 0 {
            padding = maxPrice * 0.1
        } else {
            padding = range * 0.1
        }

        let paddedMin = minPrice - padding
        let paddedMax = maxPrice + padding

        return ZStack {
            if isLoading {
                ProgressView("Загрузка...")
            } else if candles.isEmpty {
                Text("Нет данных")
            } else {
                Chart(candles) { candle in
                    RuleMark(
                        x: .value("Дата", candle.date),
                        yStart: .value("Открытие", candle.open),
                        yEnd: .value("Закрытие", candle.close)
                    )
                    .foregroundStyle(candle.close >= candle.open ? Color.green : Color.red)
                }
                .chartYScale(domain: paddedMin...paddedMax)
            }
        }
        .padding(.leading, 30)
        .padding(.trailing, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { loadCandles() }
    }

    private func loadCandles() {
        isLoading = true
        Candle.fetchCandles(ticker: "SBER") { result in
            DispatchQueue.main.async {
                print("sber")
                self.isLoading = false
                if case .success(let candles) = result {
                    self.candles = candles
                    print("Загружено свечей: \(candles.count)")
                }
            }
        }
    }
}

#Preview {
    ChartView()
}
