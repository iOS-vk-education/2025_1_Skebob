//
//  ChartView.swift
//  MyInvestor
//
//  Created by Максим Скориков on 18.12.2025.
//

import SwiftUI
import Charts

struct ChartView: View {
    
    let ticker: String
    let period: ChartPeriod
    
    @State private var candles: [Candle] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var hoveredCandle: Candle?
    @State private var proxy: ChartProxy?

    var body: some View {
        
        let prices = candles.map { $0.close }
        let minPrice = prices.min() ?? 0
        let maxPrice = prices.max() ?? 1
        let range = maxPrice - minPrice
        let padding: Double = range == 0 ? maxPrice * 0.1 : range * 0.1
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
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white)
                        AxisGridLine()
                            .foregroundStyle(.gray.opacity(0.3))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white)
                        AxisGridLine()
                            .foregroundStyle(.gray.opacity(0.3))
                    }
                }
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        // Находим дату под пальцем
                                        if let date = proxy.value(atX: value.location.x) as Date? {
                                            // Ищем ближайшую свечу
                                            hoveredCandle = findNearestCandle(to: date)
                                            self.proxy = proxy
                                        }
                                    }
                                    .onEnded { _ in
                                        hoveredCandle = nil
                                    }
                            )
                    }
                }
                
                // 🎯 Рисуем тултип поверх графика, если есть активная свеча
                if let candle = hoveredCandle, let proxy = proxy {
                    tooltipView(for: candle, proxy: proxy)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.1), value: hoveredCandle)
                }
            }
        }
        .padding(.leading, 30)
        .padding(.trailing, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { loadCandles() }
        .onChange(of: period) { _, _ in
            hoveredCandle = nil
            loadCandles()
        }
    }
    
    @ViewBuilder
    private func tooltipView(for candle: Candle, proxy: ChartProxy) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(formatDate(candle.date))
                .font(.caption2)
                .foregroundColor(.gray)
            
            HStack(spacing: 8) {
                Text("\(candle.close, specifier: "%.2f") ₽")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                let change = candle.close - candle.open
                let sign = change >= 0 ? "+" : ""
                Text("\(sign)\(change, specifier: "%.2f")")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(change >= 0 ? .green : .red)
            }
        }
        .padding(8)
        .background(Color(hex: "2C2C2E"))
        .cornerRadius(6)
        .shadow(color: .black.opacity(0.5), radius: 4)
        .position(positionFor(date: candle.date, proxy: proxy))
    }
    
    private func findNearestCandle(to date: Date) -> Candle? {
        candles.min(by: {
            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
        })
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func positionFor(date: Date, proxy: ChartProxy) -> CGPoint {
        guard let xPos = proxy.position(forX: date) else { return CGPoint(x: 0, y: 0) }
        return CGPoint(x: xPos, y: 40)
    }

    private func loadCandles() {
        isLoading = true
        
        Candle.fetchCandles(ticker: ticker, period: period) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let candles):
                    self.candles = candles
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Error loading candles for \(ticker): \(error)")
                }
            }
        }
    }
}

#Preview {
    ChartView(ticker: "SBER", period: .month)
}
