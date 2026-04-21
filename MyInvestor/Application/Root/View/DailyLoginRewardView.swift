import SwiftUI

struct DailyLoginRewardView: View {
    let day: Int
    let amount: Double
    let onClose: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)
    private let totalDaysInCycle = 30
    private var cycleDay: Int { ((max(day, 1) - 1) % totalDaysInCycle) + 1 }
    private var progress: Double { Double(cycleDay) / Double(totalDaysInCycle) }

    var body: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Text("Daily Login Rewards")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                }

                rewardHeader
                progressSection
                rewardGrid

                Button(action: onClose) {
                    Text("Забрать \(Int(amount)) $")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "131A2A"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
    }

    private var rewardHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundColor(.orange)
                Text("Ежедневная награда")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
            }

            Text("Календарный день \(cycleDay) из \(totalDaysInCycle)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.65))

            Text("Сегодня: +\(Int(amount)) $")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            Text("Серия входов: \(day) дней")
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(.yellow)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Прогресс наград")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Text("\(cycleDay)/\(totalDaysInCycle)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.orange)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 10)

                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 10)
                }
            }
            .frame(height: 10)
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    private var rewardGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(1...totalDaysInCycle, id: \.self) { value in
                let amount = Int(rewardAmount(for: value))
                VStack(spacing: 6) {
                    Text("DAY \(value)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(amount) $")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(cellBackground(for: value))
                .cornerRadius(10)
            }
        }
    }

    private func rewardAmount(for day: Int) -> Double {
        let weeklyPattern: [Double] = [100, 150, 200, 300, 400, 550, 750]
        let index = (max(day, 1) - 1) % weeklyPattern.count
        return weeklyPattern[index]
    }

    private func cellBackground(for value: Int) -> Color {
        if value == cycleDay {
            return Color.orange.opacity(0.85)
        }
        if value < cycleDay {
            return Color.green.opacity(0.35)
        }
        return Color.blue.opacity(0.35)
    }
}
