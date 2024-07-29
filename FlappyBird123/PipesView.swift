//
//  PipesView.swift
//  FlappyBird123
//
//  Created by Дмитрий Цепилов on 29.07.2024.
//

import SwiftUI

struct PipesView: View {
    let topPipeHeight: Double
    let pipeWidth: Double
    let pipeSpacing: Double
    
    var body: some View {
        // Верхняя труба
        GeometryReader { geometry in
            VStack {
                Image(.flappeBirdPipe)
                    .resizable()
                    .rotationEffect(.degrees(180))
                .frame(width: pipeWidth, height: topPipeHeight)
                
                //Пространство между трубами
                Spacer(minLength: pipeSpacing)
                
                //Нижняя труба
                Image(.flappeBirdPipe)
                    .resizable()
                    .frame(
                        width: pipeWidth,
                        height: geometry.size.height - topPipeHeight - pipeSpacing)
            }
        }
        
        
        
    }
}

#Preview {
    PipesView(topPipeHeight: 300, pipeWidth: 100, pipeSpacing: 100)
}
