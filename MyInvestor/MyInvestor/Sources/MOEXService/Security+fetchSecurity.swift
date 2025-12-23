//
//  Security+fetchSecurity.swift
//  MyInvestor
//
//  Created by Максим Скориков on 19.12.2025.
//

import Foundation

struct Security: Identifiable {
    
    let id = UUID()
    let secid: String
    let name: String
    let price: Double
    let changePercent: Double
}

extension Security {
    
    static func fetchSecurityAsync() async throws -> [Security] {
        return try await withCheckedThrowingContinuation { continuation in
            fetchSecurity { result in
                continuation.resume(with: result)
            }
        }
    }
    
    static func fetchSecurity(completion: @escaping (Result<[Security], Error>) -> Void) {
        guard let url = URL(string: "https://iss.moex.com/iss/engines/stock/markets/shares/securities.json?" +
                            "iss.only=securities,marketdata&" +
                            "securities.columns=SECID,SHORTNAME&" +
                            "marketdata.columns=SECID,LAST,LASTCHANGEPRCNT") else {
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
                      let securities = json["securities"] as? [String: Any],
                      let marketdata = json["marketdata"] as? [String: Any],
                      let secColumns = securities["columns"] as? [String],
                      let secRows = securities["data"] as? [[Any]],
                      let mdColumns = marketdata["columns"] as? [String],
                      let mdRows = marketdata["data"] as? [[Any]] else {
                    throw NSError(domain: "MOEX", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])
                }

                guard let secidSecIdx = secColumns.firstIndex(of: "SECID"),
                      let shortnameSecIdx = secColumns.firstIndex(of: "SHORTNAME"),
                      let secidMdIdx = mdColumns.firstIndex(of: "SECID"),
                      let lastIdx = mdColumns.firstIndex(of: "LAST"),
                      let changePrcntIdx = mdColumns.firstIndex(of: "LASTCHANGEPRCNT") else {
                    throw NSError(domain: "MOEX", code: 1, userInfo: [NSLocalizedDescriptionKey: "Required columns missing"])
                }

                let pairs = secRows.compactMap { row -> (String, String)? in
                    guard secidSecIdx < row.count,
                          let secid = row[secidSecIdx] as? String else { return nil }
                    let name = (shortnameSecIdx < row.count) ? (row[shortnameSecIdx] as? String) ?? secid : secid
                    return (secid, name)
                }

                let secDict = Dictionary(pairs, uniquingKeysWith: { first, _ in first })

                var securityList: [Security] = []
                for row in mdRows {
                    guard secidMdIdx < row.count,
                          let secid = row[secidMdIdx] as? String,
                          let last = row[lastIdx] as? Double else { continue }

                    let change = (changePrcntIdx < row.count) ? (row[changePrcntIdx] as? Double) ?? 0.0 : 0.0
                    let name = secDict[secid] ?? secid

                    securityList.append(Security(
                        secid: secid,
                        name: name,
                        price: last,
                        changePercent: change
                    ))
                }
                completion(.success(Array(securityList)))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
