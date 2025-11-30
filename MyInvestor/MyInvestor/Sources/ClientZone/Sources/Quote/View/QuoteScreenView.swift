//
//  Created by Dmitriy Permyakov on 21.11.2025.
//  Copyright © 2025 Skebob. All rights reserved.
//

import SwiftUI

struct QuoteScreenView: View {

    var body: some View {
        VStack(spacing: 16) {
            someSectionTitle
            buttonContainer
        }
    }
}

// MARK: - UI Subviews

private extension QuoteScreenView {

    var someSectionTitle: some View {
        VStack(spacing: 16) {
            Text("Просто текст 1")
            Text("Просто текст 2")
        }
    }

    var buttonContainer: some View {
        HStack(spacing: 16) {
            Button {
                // TODO: Добавить обработку нажатия
            } label: {
                Text("Кнопка 1")
                    .foregroundStyle(SKBColor.mainAppColor.suiColor)
            }
            .buttonStyle(.bordered)

            Button {
                // TODO: Добавить обработку нажатия
            } label: {
                Text("Кнопка 2")
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Preview

#Preview {
    QuoteScreenView()
}
