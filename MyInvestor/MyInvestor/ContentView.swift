//
//  ContentView.swift
//  Application
//
//  Created by Максим Скориков on 28.10.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selected = 1

    var body: some View {
        ZStack {
            Color(red: 15/255, green: 15/255, blue: 15/255)
                .ignoresSafeArea()
            VStack {
                ZStack {
                    if selected == 1 {
                        QuotesView()
                    } else if selected == 2 {
                        RatingView()
                    } else if selected == 3 {
                        PortfolioView()
                    } else if selected == 4 {
                        ProfileView()
                    } else if selected == 5 {
                        SettingsView()
                    }
                }
                Spacer()
                Nav_Bar(selected: $selected)
            }
        }
    }
}

struct QuotesView: View {
    var body: some View {
        Text("QuotesView")
            .foregroundColor(.white)
    }
}

struct RatingView: View {
    var body: some View {
        Text("RatingView")
            .foregroundColor(.white)
    }
}

struct PortfolioView: View {
    var body: some View {
        Text("PortfolioView")
            .foregroundColor(.white)
    }
}

struct ProfileView: View {
    var body: some View {
        Text("ProfileView")
            .foregroundColor(.white)
    }
}

struct SettingsView: View {
    var body: some View {
        Text("SettingsView")
            .foregroundColor(.white)
    }
}

struct Nav_Bar: View {
    @Binding var selected: Int
    var body: some View {
        HStack {
            Button{
                self.selected = 1
            } label: {
                VStack{
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(5)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    Text("Котировки")
                        .font(.system(size: 13))
                }
                .foregroundColor(selected == 1 ? .white : .gray)
            }
            Button{
                self.selected = 2
            } label: {
                VStack{
                    Image(systemName: "star")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(5)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    Text("Рейтинг")
                        .font(.system(size: 13))
                }
                .foregroundColor(selected == 2 ? .white : .gray)
            }
            Button{
                self.selected = 3
            } label: {
                VStack{
                    Image(systemName: "briefcase")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(5)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    Text("Портфель")
                        .font(.system(size: 13))
                }
                .foregroundColor(selected == 3 ? .white : .gray)
            }
            Button{
                self.selected = 4
            } label: {
                VStack{
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(5)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    Text("Профиль")
                        .font(.system(size: 13))
                }
                .foregroundColor(selected == 4 ? .white : .gray)
            }
            Button{
                self.selected = 5
            } label: {
                VStack{
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(5)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    Text("Настройки")
                        .font(.system(size: 13))
                }
            }
            .foregroundColor(selected == 5 ? .white : .gray)
        }
        .frame(maxWidth: .infinity)
        .background(Color(red: 245/255, green: 158/255, blue: 11/255))
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    ContentView()
}
