//
//  ContentView.swift
//  Application
//
//  Created by Максим Скориков on 28.10.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack{
            Spacer()
            HStack {
                Button{
                    print("a")
                } label: {
                    VStack{
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Text("Котировки")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(.white)
                }
                Button{
                    print("a")
                } label: {
                    VStack{
                        Image(systemName: "star")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Text("Рейтинг")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(.gray)
                }
                Button{
                    print("a")
                } label: {
                    VStack{
                        Image(systemName: "briefcase")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Text("Портфель")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(.gray)
                }
                Button{
                    print("a")
                } label: {
                    VStack{
                        Image(systemName: "person")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Text("Профиль")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(.gray)
                }
                Button{
                    print("a")
                } label: {
                    VStack{
                        Image(systemName: "gearshape")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Text("Настройки")
                            .font(.system(size: 13))
                    }
                }
                .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .background(Color(red: 245/255, green: 158/255, blue: 11/255))
        }
        .background(Color(red: 15/255, green: 15/255, blue: 15/255))
    }
}

#Preview {
    ContentView()
}
