//
//  SettingsScreenView.swift
//  MyInvestor
//
//  Created by Максим Скориков on 23.12.2025.
//

import SwiftUI
import MessageUI

struct SettingsScreenView: View {
    
    // MARK: - Settings State
    @AppStorage("portfolio_alerts") private var portfolioAlerts = true
    @AppStorage("cache_duration_hours") private var cacheDuration: Int = 24
    
    @State private var showingClearCacheAlert = false
    @State private var cacheCleared = false
    @State private var clearedSize: String = ""
    @State private var currentCacheSize: String = "…"
    @State private var showingMailComposer = false
    @State private var mailResult: MailResult? = nil
    
    var body: some View {
        ZStack {
            Color(hex: "161514").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Data Section
                    SettingsSection(title: "Данные и кеш", icon: "database.fill") {
                        
                        InfoRow(
                            title: "Занято кешем",
                            value: currentCacheSize,
                            icon: "circle.fill"
                        )
                        .onAppear { updateCacheSize() }
                        
                        ButtonRow(
                            title: "Очистить кеш",
                            subtitle: "Освободить место, обновить данные",
                            icon: "trash.fill",
                            action: { showingClearCacheAlert = true },
                            destructive: true
                        )
                    }
                    
                    // MARK: - About Section
                    SettingsSection(title: "О приложении", icon: "info.circle.fill") {
                        InfoRow(
                            title: "Версия",
                            value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
                            icon: "tag.fill"
                        )
                        
                        if MFMailComposeViewController.canSendMail() {
                            ButtonRow(
                                title: "Связаться с поддержкой",
                                icon: "envelope.fill",
                                action: { showingMailComposer = true }
                            )
                        } else {
                            ButtonRow(
                                title: "Поддержка (почта не настроена)",
                                subtitle: "Настройте почтовый ящик в Настройках",
                                icon: "exclamationmark.triangle.fill",
                                action: { openSettingsForMail() },
                                destructive: false
                            )
                        }
                    }
                    
                    // MARK: - Footer
                    Text("MyInvestor © 2026")
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.7))
                        .padding(.bottom, 32)
                }
                .padding(.top, 80)
                .padding(.horizontal, 16)
            }
            .onAppear {
                updateCacheSize()
            }
            
            // MARK: - Cache Cleared Toast
            if cacheCleared {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                        Text("Очищено \(clearedSize)")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.9))
                    .cornerRadius(12)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut(duration: 0.3), value: cacheCleared)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation { cacheCleared = false }
                    }
                }
            }
            
            if let result = mailResult {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: result.icon)
                            .font(.caption)
                        Text(result.message)
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(result.color.opacity(0.9))
                    .cornerRadius(12)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut(duration: 0.3), value: mailResult)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation { mailResult = nil }
                    }
                }
            }
        }
        .alert("Очистка кеша", isPresented: $showingClearCacheAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Очистить", role: .destructive) {
                clearCache()
            }
        } message: {
            Text("Это удалит сохранённые котировки. Данные загрузятся заново при следующем открытии приложения.")
        }
        .sheet(isPresented: $showingMailComposer) {
            MailComposerView(
                isPresented: $showingMailComposer,
                toRecipients: ["maks.skorikov.05@mail.ru"],
                subject: "MyInvestor — Вопрос от пользователя",
                messageBody: """
                Здравствуйте!

                У меня возник вопрос/проблема по приложению MyInvestor.


                ---
                Устройство: \(UIDevice.current.model)
                Версия iOS: \(UIDevice.current.systemVersion)
                Версия приложения: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "неизвестно")
                """,
                onResult: { result in
                    mailResult = result
                }
            )
        }
    }
    
    // MARK: - Cache Helpers
    
    private func updateCacheSize() {
        let urlCacheSize = URLCache.shared.currentDiskUsage
        let userDefaultsSize = getUserDefaultsCacheSize()
        let totalBytes = urlCacheSize + userDefaultsSize
        currentCacheSize = formatBytes(totalBytes)
    }
    
    private func clearCache() {
        let beforeURLCache = URLCache.shared.currentDiskUsage
        let beforeUserDefaults = getUserDefaultsCacheSize()
        
        URLCache.shared.removeAllCachedResponses()
        
        UserDefaults.standard.removeObject(forKey: "cached_quotes")
        UserDefaults.standard.removeObject(forKey: "cached_portfolio")
        UserDefaults.standard.removeObject(forKey: "cached_leaderboard")
        UserDefaults.standard.synchronize()
        
        let clearedBytes = beforeURLCache + beforeUserDefaults
        clearedSize = formatBytes(clearedBytes)
        
        cacheCleared = true
        currentCacheSize = formatBytes(0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            updateCacheSize()
        }
    }
    
    private func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.includesUnit = true
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    private func getUserDefaultsCacheSize() -> Int {
        var totalSize = 0
        let cacheKeys = ["cached_quotes", "cached_portfolio", "cached_leaderboard"]
        
        for key in cacheKeys {
            if let data = UserDefaults.standard.object(forKey: key) as? Data {
                totalSize += data.count
            } else if let string = UserDefaults.standard.object(forKey: key) as? String {
                totalSize += string.utf8.count
            } else if let array = UserDefaults.standard.object(forKey: key) as? [Any] {
                if let jsonData = try? JSONSerialization.data(withJSONObject: array) {
                    totalSize += jsonData.count
                }
            }
        }
        return totalSize
    }
    
    private func openSettingsForMail() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Mail Support

enum MailResult {
    case sent, cancelled, failed, saved
    
    var message: String {
        switch self {
        case .sent: return "Письмо отправлено"
        case .cancelled: return "Отправка отменена"
        case .failed: return "Ошибка отправки"
        case .saved: return "Письмо сохранено в черновиках"
        }
    }
    
    var icon: String {
        switch self {
        case .sent: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        case .failed: return "exclamationmark.triangle.fill"
        case .saved: return "doc.text.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .sent: return .green
        case .cancelled: return .gray
        case .failed: return .red
        case .saved: return .orange
        }
    }
}

struct MailComposerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let toRecipients: [String]
    let subject: String
    let messageBody: String
    let onResult: ((MailResult) -> Void)?
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(toRecipients)
        composer.setSubject(subject)
        composer.setMessageBody(messageBody, isHTML: false)
        composer.navigationBar.tintColor = UIColor(Color(red: 1.0, green: 0.5, blue: 0.0))
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposerView
        
        init(_ parent: MailComposerView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.isPresented = false
            
            let mailResult: MailResult = {
                switch result {
                case .sent: return .sent
                case .cancelled: return .cancelled
                case .failed: return .failed
                case .saved: return .saved
                @unknown default: return .failed
                }
            }()
            
            parent.onResult?(mailResult)
        }
    }
}

// MARK: - Reusable Components

private struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.0))
                    .font(.caption)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

private struct ToggleRow: View {
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    
    init(title: String, subtitle: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(red: 1.0, green: 0.5, blue: 0.0))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

private struct InfoRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

private struct ButtonRow: View {
    let title: String
    let subtitle: String?
    let icon: String
    let action: () -> Void
    let destructive: Bool
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        action: @escaping () -> Void,
        destructive: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.action = action
        self.destructive = destructive
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(destructive ? .red : .gray)
                    .frame(width: 20)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14))
                        .foregroundColor(destructive ? .red : .white)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsScreenView()
}
