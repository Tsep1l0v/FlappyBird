//
//  GameView.swift
//  FlappyBird123
//
//  Created by Дмитрий Цепилов on 29.07.2024.
//

import SwiftUI
import AVFoundation

// Состояние игры
enum GameState {
    case ready, active, stopped
}

struct GameView: View {
    @State private var gameState: GameState = .ready
    @State private var birdPosition = CGPoint(x: 100, y: 300)
    @State private var birdVelocuty = CGVector(dx: 0, dy: 0)
    @State private var topPipeHeight = Double.random(in: 100...500)
    @State private var pipeOffset = 0.0
    @State private var passedPipe = false
    @State private var backgroundMusicPlayer: AVAudioPlayer?
    
    @State private var scores = 0
    @AppStorage(wrappedValue: 0, "highScore") private var highScore: Int
    @State private var lastUpdateTime = Date()
    
    private let defaultSettings = GameSettings.defaultSettings
    
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    
    
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    Image(.flappyBirdBackground)
                        .resizable()
                        .scaleEffect(CGSize(width: geometry.size.width * 0.003, height: geometry.size.height * 0.0017))
                    
                    BirdView(birdSize: defaultSettings.birdSize)
                        .position(birdPosition)
                    
                    PipesView(topPipeHeight: topPipeHeight, pipeWidth: defaultSettings.pipeWidth, pipeSpacing: defaultSettings.pipeSpacing)
                        .offset(x: geometry.size.width + pipeOffset)
                    
                    
                    if gameState == .ready {
                        Button(action: playButtonAction) {
                            Image(systemName: "play.fill")
                                .scaleEffect(x: 3.5, y: 3.5)
                        }
                        .foregroundColor(.white)
                        
                        
                    }
                    if gameState == .stopped {
                        ResultView(score: scores, highScore: highScore) {
                            resetGame()
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Text(scores.formatted())
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                            .padding()
                    }
                }
                .onTapGesture {
                    if gameState == .active {
                        // Устанавливаем вертикальную скорость вверх
                        birdVelocuty = CGVector(dx: 0, dy: defaultSettings.jumpVelocity)
                    }
                }
                .onReceive(timer) { currentTime in
                                    guard gameState == .active else {
                                        if gameState == .stopped {
                                            stopBackgroundMusic()
                                        }
                                        return
                                    }
                                    let deltaTime = currentTime.timeIntervalSince(lastUpdateTime)
                                    
                                    applyGravity(deltaTime: deltaTime)
                                    updateBirdPosition(deltaTime: deltaTime)
                                    checkBoundaries(geometry: geometry)
                                    updatePipePosition(deltaTime: deltaTime)
                                    resetPipePositionIfNeeded(geometry: geometry)
                                    
                                    if checkCollision(with: geometry) {
                                        gameState = .stopped
                                    }
                                    
                                    updateScoresAndhighScore(geometry: geometry)
                                    
                                    lastUpdateTime = currentTime
                                }
                                .onAppear {
                                    playBackgroundMusic()
                                }
                            }
                        }
                    }
    
    // Действия по нажатию на кнопку Play
    private func playButtonAction() {
        gameState = .active
        lastUpdateTime = Date()
        playBackgroundMusic()
    }
    
    //  Действия по нажатию кнопки Заново
    private func resetGame() {
        birdPosition = CGPoint(x: 100, y: 300)
        birdVelocuty = CGVector(dx: 0, dy: 0)
        pipeOffset = 0
        topPipeHeight = Double.random(in: defaultSettings.minePipeHeight...defaultSettings.maxePipeHeight)
        scores = 0
        gameState = .ready
    }
    
    // Эффект гравитации
    private func applyGravity(deltaTime: TimeInterval) {
        birdVelocuty.dy += Double(defaultSettings.gravity * deltaTime)
    }
    
    // Обновление позиции птицы,  учитывая ее текущий скокрость.
    private func updateBirdPosition(deltaTime: TimeInterval) {
        birdPosition.y += birdVelocuty.dy * Double(deltaTime)
    }
    // Остановка падения позиции птицы, учитывая ее текущую скоростью
    // Ограничение высоты полета
    private func checkBoundaries(geometry: GeometryProxy) {
        // ПРоверка не достигла ли птица верхней границы экрана
        if birdPosition.y <= 0 {
            birdPosition.y = 0
        }
        // Проверка не достигла ли птица грунта
        if birdPosition.y > geometry.size.height - defaultSettings.groundHeight - defaultSettings.birdSize / 2 {
            birdPosition.y = geometry.size.height - defaultSettings.groundHeight - defaultSettings.birdSize / 2
            birdVelocuty.dy = 0
        }
    }
    
    // Обновление положение столбов
    private func updatePipePosition(deltaTime: TimeInterval) {
        pipeOffset -= Double(defaultSettings.pipeSpeed * deltaTime)
        
    }
    
    // Установка столбов на начальную позицию по завершению цикла
    private func resetPipePositionIfNeeded(geometry: GeometryProxy) {
        if pipeOffset <= -geometry.size.width - defaultSettings.pipeWidth {
            pipeOffset = 0
            topPipeHeight = Double.random(in: defaultSettings.minePipeHeight...defaultSettings.maxePipeHeight)
        }
    }
    
    private func checkCollision(with geometry: GeometryProxy) -> Bool {
        
        // СОздаем прямоугольник вокруг птицы
        // Позиция птицы birdPosition устанавливается в центр прямоугольника
        let birdFrame = CGRect(x: birdPosition.x - defaultSettings.birdRadius / 2, y: birdPosition.y - defaultSettings.birdRadius / 2, width: defaultSettings.birdRadius, height: defaultSettings.birdRadius)
        
        // СОздаем прямоугольник вокруг верхнего столба
        let topPipeFrame = CGRect(x: geometry.size.width + pipeOffset, y: 0, width: defaultSettings.pipeWidth, height: topPipeHeight)
        
        // СОздаем прямоугольник вокруг нижнего столба
        let bottomPipeFrame = CGRect(x: geometry.size.width + pipeOffset, y: topPipeHeight + defaultSettings.pipeSpacing, width: defaultSettings.pipeWidth, height: topPipeHeight)
        
        // Функция возвращает true если прямоугольник птицы
        // пересекается с прямоугольником любого из столбов
        return birdFrame.intersects(topPipeFrame) || birdFrame.intersects(bottomPipeFrame)
        
    }
    
    // Функция для обновления набранных очков и рекорда
    private func updateScoresAndhighScore(geometry: GeometryProxy) {
        if pipeOffset + defaultSettings.pipeWidth + geometry.size.width < birdPosition.x && !passedPipe {
            scores += 1
            // Обновление рекорда
            if scores > highScore {
                highScore = scores
            }
            // Избегаем повторного увеличения счета
            passedPipe = true
        } else if pipeOffset + geometry.size.width > birdPosition.x {
            // Сброс положения труб после их выхода за пределы жкрана
            passedPipe = false
        }
    }
    
    private func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "background-music", withExtension: "mp3") else {
            print("Could not find the audio file.")
            return
        }

        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Бесконечный цикл
            backgroundMusicPlayer?.play()
        } catch {
            print("Could not create audio player: \(error)")
        }
    }
    private func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
    
    
}

#Preview {
    GameView()
}
