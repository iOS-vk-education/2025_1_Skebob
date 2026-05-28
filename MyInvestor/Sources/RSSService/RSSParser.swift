//
//  RSSParser.swift
//  MyInvestor
//
//  Created by Максим Скориков on 28.03.2026.
//

import Foundation

class RSSParser: NSObject, XMLParserDelegate {
    private var items: [RSSItem] = []
    private var current: [String: String] = [:]
    private var currentElement: String?
    private var mediaUrl: String?
    
    func parse(data: Data) async -> [RSSItem] {
        items = []
        current = [:]
        currentElement = nil
        mediaUrl = nil
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        
        return items
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {
        
        if elementName == "item" {
            current = [:]
            mediaUrl = nil
        }
        if elementName == "media:content" || elementName == "enclosure" {
            mediaUrl = attributeDict["url"]
        }
        
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let element = currentElement else { return }
        if ["title", "link", "description", "pubDate", "category"].contains(element) {
            current[element, default: ""] += string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" {
            var imageUrl = mediaUrl
            
            if imageUrl == nil, let desc = current["description"] {
                imageUrl = extractImageFromHTML(desc)
            }
            
            let item = RSSItem(
                title: current["title"] ?? "",
                link: current["link"] ?? "",
                description: current["description"],
                pubDate: current["pubDate"] ?? "",
                imageUrl: imageUrl,
                category: current["category"]
            )
            items.append(item)
        }
        
        if elementName == currentElement {
            currentElement = nil
        }
    }
    private func extractImageFromHTML(_ html: String) -> String? {
        let pattern = "<img[^>]+src=\"([^\"]+)\""
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(html.startIndex..., in: html)
        
        if let match = regex?.firstMatch(in: html, options: [], range: range),
           let srcRange = Range(match.range(at: 1), in: html) {
            return String(html[srcRange])
        }
        return nil
    }
}
