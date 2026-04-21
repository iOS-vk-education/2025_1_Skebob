//
//  DateInput.swift
//  MyInvestor
//
//  Created by Максим Скориков on 06.03.2026.
//

import SwiftUI

struct DateInput: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var textInput: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("День рождения")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                TextField("ДД.ММ.ГГГГ", text: $textInput)
                    .keyboardType(.numberPad)
                    .foregroundColor(.white)
                    .onChange(of: textInput) { newValue in
                        formatInput(newValue)
                    }
                
                if !textInput.isEmpty {
                    Button {
                        textInput = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.5, blue: 0.0),
                                Color(red: 0.9, green: 0.3, blue: 0.1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .onAppear {
            if textInput.isEmpty && !viewModel.birthdayText.isEmpty {
                textInput = viewModel.birthdayText
            } else if textInput.isEmpty {
                textInput = formatDateForInput(viewModel.birthday)
            }
        }
        .onChange(of: viewModel.birthday) { newDate in
            textInput = formatDateForInput(newDate)
        }
    }
    
    private func formatInput(_ value: String) {
        let numbers = value.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        var formatted = ""
        var index = numbers.startIndex
        
        if numbers.count >= 2 {
            let dayEnd = numbers.index(numbers.startIndex, offsetBy: min(2, numbers.count))
            formatted = String(numbers[..<dayEnd])
            index = dayEnd
            if numbers.count > 2 { formatted += "." }
        } else {
            viewModel.birthdayText = numbers
            updateDate(from: numbers)
            return
        }
        
        if numbers.count >= 4 {
            let monthEnd = numbers.index(index, offsetBy: min(2, numbers.count - 2))
            formatted += String(numbers[index..<monthEnd])
            index = monthEnd
            if numbers.count > 4 { formatted += "." }
        } else if numbers.count > 2 {
            formatted += String(numbers[index...])
        }

        if numbers.count >= 8 {
            let yearEnd = numbers.index(index, offsetBy: min(4, numbers.count - 4))
            formatted += String(numbers[index..<yearEnd])
        } else if numbers.count > 4 {
            formatted += String(numbers[index...])
        }
        
        if formatted != textInput {
            textInput = formatted
        }
        
        updateDate(from: formatted)
    }
    
    private func updateDate(from text: String) {
        let numbers = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard numbers.count >= 8 else { return }
        
        let day = Int(String(numbers.prefix(2))) ?? 1
        let month = Int(String(numbers.dropFirst(2).prefix(2))) ?? 1
        let year = Int(String(numbers.dropFirst(4).prefix(4))) ?? 2000
        
        guard day >= 1 && day <= 31 else { return }
        guard month >= 1 && month <= 12 else { return }
        guard year >= 1900 && year <= 2025 else { return }
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        
        if let newDate = Calendar.current.date(from: components) {
            viewModel.birthday = newDate
        }
    }
    
    private func formatDateForInput(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let day = String(format: "%02d", components.day ?? 1)
        let month = String(format: "%02d", components.month ?? 1)
        let year = components.year ?? 2000
        return "\(day).\(month).\(year)"
    }
}
