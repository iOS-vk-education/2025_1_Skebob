//
//  ChartPeriod.swift
//  MyInvestor
//
//  Created by Максим Скориков on 19.02.2026.
//

enum ChartPeriod: String, CaseIterable, Identifiable {
    case day, week, month, halfYear, year, fiveYears
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .day: return "День"
        case .week: return "Неделя"
        case .month: return "Месяц"
        case .halfYear: return "6 мес"
        case .year: return "Год"
        case .fiveYears: return "5 лет"
        }
    }
}
