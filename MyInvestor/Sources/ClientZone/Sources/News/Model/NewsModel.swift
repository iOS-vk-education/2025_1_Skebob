//
//  NewsModel.swift
//  MyInvestor
//
//  Created by Максим Скориков on 28.03.2026.
//

import Foundation

struct RSSItem: Codable {
    let title: String
    let link: String
    let description: String?
    let pubDate: String
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case title, link, description, pubDate
        case imageUrl = "media:content"
    }
}

struct RSSChannel: Codable {
    let item: [RSSItem]
}

struct RSSFeed: Codable {
    let channel: RSSChannel
}

struct NewsItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let summary: String
    let source: String
    let date: Date
    let url: URL
    let imageUrl: URL?
}

struct NewsSource {
    let name: String
    let url: String
}

extension NewsSource {
    static let defaults: [NewsSource] = [
        .init(name: "Интерфакс", url: "https://www.interfax.ru/rss.asp"),
    ]
}
