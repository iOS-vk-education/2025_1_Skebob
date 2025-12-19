//
//  Candle+fetcCandles.swift
//  MyInvestor
//
//  Created by Максим Скориков on 16.12.2025.
//

import SwiftUI
import Foundation
import Charts

struct Candle: Identifiable, Equatable {
    
    let id = UUID()
    let date: Date
    let open: Double
    let close: Double
}

extension Candle {
    
    static func fetchCandles(
        ticker: String,
        interval: Int = 24,
        completion: @escaping (Result<[Candle], Error>) -> Void) {
            
        let today = Date()
        let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: today)!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fromStr = formatter.string(from: threeMonthsAgo)
        let tillStr = formatter.string(from: today)
            
        guard let url = URL(string: "https://iss.moex.com/iss/engines/stock/markets/shares/securities/\(ticker)/candles.json?from=\(fromStr)&till=\(tillStr)&interval=\(interval)") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let candlesJSON = json["candles"] as? [String: Any],
                      let columns = candlesJSON["columns"] as? [String],
                      let rows = candlesJSON["data"] as? [[Any]] else {
                    completion(.failure(NSError(domain: "MOEX", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }

                guard let dateIndex = columns.firstIndex(of: "begin"),
                      let openIndex = columns.firstIndex(of: "open"),
                      let closeIndex = columns.firstIndex(of: "close") else {
                    completion(.failure(NSError(domain: "MOEX", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing columns"])))
                    return
                }

                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                df.timeZone = TimeZone(secondsFromGMT: 0)

                var candles: [Candle] = []
                for row in rows {
                    if dateIndex < row.count,
                       closeIndex < row.count,
                       let dateString = row[dateIndex] as? String,
                       let open = row[openIndex] as? Double,
                       let close = row[closeIndex] as? Double,
                       let date = df.date(from: dateString) {
                        candles.append(Candle(date: date, open: open, close: close))
                    }
                }
                candles.sort { $0.date < $1.date }
                completion(.success(candles))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
