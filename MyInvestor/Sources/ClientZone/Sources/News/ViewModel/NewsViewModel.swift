//
//  NewsViewModel.swift
//  MyInvestor
//
//  Created by Максим Скориков on 28.03.2026.
//

import Foundation
import Combine

@MainActor
class NewsViewModel: ObservableObject {
    
    @Published var items: [NewsItem] = []
    @Published var loading = false
    
    private let parser = RSSParser()
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return f
    }()
    
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }()
    
    func load(tickers: [String]? = nil, append: Bool = false) async {
        
        loading = true
        
        var all: [NewsItem] = []
        
        for source in NewsSource.defaults {
            
            guard let url = URL(string: source.url) else { continue }
            
            do {
                let (data, _) = try await urlSession.data(from: url)
                let rss = await parser.parse(data: data)
                
                let parsed = rss.compactMap { item -> NewsItem? in
                    if item.category != "Экономика" && item.category != "Бизнес" {
                        return nil
                    }
                    guard let url = URL(string: item.link),
                          let date = dateFormatter.date(from: item.pubDate) else {
                        return nil
                    }
                    
                    let clean = item.description?
                        .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                        .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        .prefix(150) ?? ""
                    
                    let imageURL = item.imageUrl.flatMap { URL(string: $0) }
                    
                    return NewsItem(
                        id: UUID(),
                        title: item.title,
                        summary: String(clean) + "...",
                        source: source.name,
                        date: date,
                        url: url,
                        imageUrl: imageURL
                    )
                }
                
                let filtered = if let tickers = tickers, !tickers.isEmpty {
                    parsed.filter { item in
                        let text = (item.title + " " + item.summary).uppercased()
                        return tickers.contains { text.contains($0.uppercased()) }
                    }
                } else {
                    parsed
                }
                
                all.append(contentsOf: filtered)
                
            } catch {
                print("Ошибка \(source.name): \(error)")
            }
        }
        
        self.items = all.sorted { $0.date > $1.date }
        loading = false
    }
}
