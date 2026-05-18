import SwiftUI

enum CellStatus: Equatable {
    case claimed, current, locked
}

struct DailyLoginRewardView: View {
    @Binding var currentDay: Int
    let amount: Double
    let onClaim: () -> Void
    let onClose: () -> Void

    @State private var isClaiming = false
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)
    private let totalDaysInCycle = 7

    private var cycleDay: Int { ((max(currentDay, 1) - 1) % totalDaysInCycle) + 1 }
    private var progress: Double { Double(cycleDay) / Double(totalDaysInCycle) }

    var body: some View {
        ZStack {
            Color(hex: "161514").ignoresSafeArea().onTapGesture { onClose() }
            VStack(spacing: 16) {
                HStack {
                    Text("Ежедневная награда").font(.system(size: 24, weight: .heavy)).foregroundColor(.white)
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.white.opacity(0.7)).font(.system(size: 24))
                    }
                }
                rewardHeader
                progressSection
                rewardGrid.animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentDay)

                Button(action: {
                    withAnimation(.easeInOut) { isClaiming = true }
                    onClaim()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isClaiming = false
                        onClose()
                    }
                }) {
                    HStack {
                        Image(systemName: "gift.fill")
                        Text("Забрать \(Int(amount)) ₽")
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(12)
                    .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .scaleEffect(isClaiming ? 0.95 : 1.0)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(hex: "131A2A"))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.orange.opacity(0.3), lineWidth: 1))
                .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10))
            .padding(.horizontal, 20)
        }
    }

    private var rewardHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "calendar.badge.checkmark").foregroundColor(.orange)
                Text("День \(cycleDay) из \(totalDaysInCycle)").font(.system(size: 16, weight: .semibold)).foregroundColor(.white.opacity(0.85))
            }
            Text("Текущая серия: \(currentDay) дней").font(.system(size: 14, weight: .medium)).foregroundColor(.white.opacity(0.6))
            HStack {
                Text("Сегодня:").foregroundColor(.white.opacity(0.7))
                Text("+\(Int(amount)) ₽").font(.system(size: 20, weight: .heavy)).foregroundColor(.yellow)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Прогресс цикла").font(.system(size: 14, weight: .semibold)).foregroundColor(.white.opacity(0.9))
                Spacer()
                Text("\(Int(progress * 100))%").font(.system(size: 13, weight: .bold)).foregroundColor(.orange)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.15)).frame(height: 8)
                    Capsule().fill(LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(geo.size.width * progress, 10), height: 8)
                }
            }.frame(height: 8)
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    private var rewardGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(1...totalDaysInCycle, id: \.self) { value in
                RewardCell(day: value, amount: rewardAmount(for: value), status: cellStatus(for: value))
            }
        }
    }

    private func cellStatus(for value: Int) -> CellStatus {
        if value < cycleDay { return .claimed }
        if value == cycleDay { return .current }
        return .locked
    }

    private func rewardAmount(for day: Int) -> Double {
        let pattern: [Double] = [100, 150, 200, 300, 400, 550, 750]
        return pattern[(max(day, 1) - 1) % pattern.count]
    }
}

struct RewardCell: View {
    let day: Int
    let amount: Double
    let status: CellStatus

    var body: some View {
        VStack(spacing: 4) {
            iconForStatus
            Text("День \(day)").font(.system(size: 10, weight: .bold)).foregroundColor(.white.opacity(0.7))
            Text("\(Int(amount))").font(.system(size: 12, weight: .heavy)).foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(backgroundForStatus)
        .cornerRadius(8)
        .overlay(status == .current ? RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 2) : nil)
    }

    private var iconForStatus: some View {
        Group {
            switch status {
            case .claimed: Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
            case .current: Image(systemName: "gift.fill").foregroundColor(.white)
            case .locked: Image(systemName: "lock.fill").foregroundColor(.white.opacity(0.3))
            }
        }.font(.system(size: 16))
    }

    private var backgroundForStatus: Color {
        switch status {
        case .claimed: Color.green.opacity(0.2)
        case .current: Color.orange.opacity(0.8)
        case .locked: Color.blue.opacity(0.15)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var day: Int = 5
        var body: some View {
            DailyLoginRewardView(currentDay: $day, amount: 400, onClaim: {}, onClose: {})
        }
    }
    return PreviewWrapper()
}
