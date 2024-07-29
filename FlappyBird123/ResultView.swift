//
//  ResultView.swift
//  FlappyBird123
//
//  Created by Дмитрий Цепилов on 29.07.2024.
//

import SwiftUI

struct ResultView: View {
    let score: Int
    let highScore: Int
    let resetAction: () -> Void
    var body: some View {
        VStack {
            Text("Конец игры")
                .font(.largeTitle)
                .foregroundColor(.black)

                .padding()
            Text("Очков: \(score)")
                .font(.title)
                .foregroundColor(.black)
            Text("Рекорд \(highScore)")
                .padding()
                .foregroundColor(.black)
            Button("Заново", action:  resetAction)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 10))
                .padding()
        }
        .background(.white.opacity(0.8))
        .clipShape(.rect(cornerRadius: 20))
    }
}

#Preview {
    ResultView(score: 5, highScore: 3, resetAction: {})
}
