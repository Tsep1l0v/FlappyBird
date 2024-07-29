//
//  GameSettings.swift
//  FlappyBird123
//
//  Created by Дмитрий Цепилов on 29.07.2024.
//

import Foundation

// Структура содержающая настройки игры
struct GameSettings {
    // ширина трубы
    let pipeWidth: Double
    // Минимальная высота трубы
    let minePipeHeight: Double
    // Максимальная высота трубы
    let maxePipeHeight: Double
    // РАсстояния между трубами
    let pipeSpacing: Double
    // Скорость движение труб
    let pipeSpeed: Double
    // Сила прыжка птицы
    let jumpVelocity: Double
    // Сила гравитации
    let gravity: Double
    // ВЫсота грунта
    let groundHeight: Double
    // размер представление птицы
    let birdSize: Double
    //  Реальный радиус птицы
    let birdRadius: Double
    
    // Возвращает экземпляр GameSettings с настройками по умолчанию
    
    static var defaultSettings: GameSettings {
        GameSettings(
            pipeWidth: 100, minePipeHeight: 100, maxePipeHeight: 500, pipeSpacing: 100, pipeSpeed: 300, jumpVelocity: -400, gravity: 1000, groundHeight: 100, birdSize: 80, birdRadius: 13)
    }
    
    
}
