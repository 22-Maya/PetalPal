//
//  ContentView.swift
//  Petal Pal
//
//  Created by Adishree Das on 7/21/25.
//
import SwiftUI
struct ContentView: View {
    var body: some View {
        VStack(spacing: 0) {
//            navbar
            HStack {
                Text("Petal Pal")
                    .font(.custom("MadimiOne-Regular", size: 28))
                    .foregroundColor(.black)
                    .padding(.leading, 20)
                Spacer()
                Image(systemName: "questionmark.circle")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.green)
                    .padding(.trailing, 20)
            }
            .frame(height: 56)
            .background(Color.white.opacity(0.7))
            
//            today's tasks section
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 25)
                    .frame(width:325, height:150)
                    .foregroundColor(Color(red: 195/255, green: 225/255, blue: 243/255))
                VStack(alignment: .leading) {
                    Text("Today's Tasks")
                        .font(.custom("MadimiOne-Regular", size:25))
                        .padding(.top, 16)
                        .padding(.leading, 20)
                    Spacer()
                }
                .frame(width: 325, height: 150, alignment: .topLeading)
            }
        }
    }
}
#Preview {
    ContentView()
}

