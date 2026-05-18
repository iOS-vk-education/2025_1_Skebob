import SwiftUI

enum DailyLoginRewardAssembly {
    static func assemble(
        currentDay: Binding<Int>,
        amount: Double,
        onClaim: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) -> some View {
        DailyLoginRewardView(
            currentDay: currentDay,
            amount: amount,
            onClaim: onClaim,
            onClose: onClose
        )
    }
}
