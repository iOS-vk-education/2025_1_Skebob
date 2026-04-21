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
        case .settings:
            "Настройки"
        }
    }

    var iconName: String {
        switch self {
        case .quotes:
            "HomeIcon"
        case .rating:
            "RatingIcon"
        case .portfolio:
            "WalletIcon"
        case .settings:
            "SettingsIcon"
        }
    }
}
