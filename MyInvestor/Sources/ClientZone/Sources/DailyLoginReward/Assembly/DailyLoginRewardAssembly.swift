import SwiftUI

enum DailyLoginRewardAssembly {

    static func assemble(day: Int, amount: Double, onClose: @escaping () -> Void) -> some View {
        DailyLoginRewardView(day: day, amount: amount, onClose: onClose)
    }
}
