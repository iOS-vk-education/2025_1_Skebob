//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import Foundation

/// Виды табов главного экрана приложения
enum SKBAppTabKind: Identifiable, Hashable, CaseIterable {

    case quotes
    case rating
    case portfolio
    case profile
    case settings
}

// MARK: - Helpers

extension SKBAppTabKind {

    var id: String {
        title
    }

    var title: String {
        switch self {
        case .quotes:
            "Котировки"
        case .rating:
            "Рейтинг"
        case .portfolio:
            "Портфель"
        case .profile:
            "Профиль"
        case .settings:
            "Настройки"
        }
    }

    var iconName: String {
        switch self {
        case .quotes:
            "chart.line.uptrend.xyaxis"
        case .rating:
            "star.fill"
        case .portfolio:
            "briefcase.fill"
        case .profile:
            "person.fill"
        case .settings:
            "gearshape.fill"
        }
    }
}
