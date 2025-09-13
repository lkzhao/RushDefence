//
//  WaveDefinition.swift
//  RushDefense
//
//  Wave spawn system data structures
//

import Foundation

// MARK: - Enemy Types
enum EnemyType: String, CaseIterable {
    case bear
    case gnome
    case lancer
    case shaman
    case skull
    case lizard
    case snake
    case spider
    case thief
    case gnoll
    case boat
    case harpoonFish
    case minotaur
    case paddleFish
    case panda
    case turtle
    case troll
}

// MARK: - Wave Definition
struct EnemySpawn {
    let enemyType: EnemyType
    let count: Int
    
    init(_ enemyType: EnemyType, count: Int) {
        self.enemyType = enemyType
        self.count = count
    }
}

struct WaveDefinition {
    let enemies: [EnemySpawn]
    let delayBeforeWave: TimeInterval
    let spawnInterval: TimeInterval
    
    init(enemies: [EnemySpawn], delayBeforeWave: TimeInterval = 5.0, spawnInterval: TimeInterval = 1.0) {
        self.enemies = enemies
        self.delayBeforeWave = delayBeforeWave
        self.spawnInterval = spawnInterval
    }
}

// MARK: - Level Configuration
struct LevelWaveConfiguration {
    let waves: [WaveDefinition]
    
    init(_ waves: [WaveDefinition]) {
        self.waves = waves
    }
}

// MARK: - Predefined Level Configurations
extension LevelWaveConfiguration {
    static let level1 = LevelWaveConfiguration([
        // Early waves - introduce basic enemies
        WaveDefinition(enemies: [EnemySpawn(.gnome, count: 15)], delayBeforeWave: 2.0, spawnInterval: 0.9),
        WaveDefinition(enemies: [EnemySpawn(.gnome, count: 20)], delayBeforeWave: 5.0, spawnInterval: 0.8),
        WaveDefinition(enemies: [EnemySpawn(.bear, count: 8)], delayBeforeWave: 7.0, spawnInterval: 1.2),
        WaveDefinition(enemies: [EnemySpawn(.gnome, count: 15), EnemySpawn(.bear, count: 5)], delayBeforeWave: 6.0, spawnInterval: 0.7),
        WaveDefinition(enemies: [EnemySpawn(.lancer, count: 12)], delayBeforeWave: 8.0, spawnInterval: 1.0),
        
        // Mid-early waves - mixed compositions
        WaveDefinition(enemies: [EnemySpawn(.gnome, count: 20), EnemySpawn(.lancer, count: 8)], delayBeforeWave: 7.0, spawnInterval: 0.6),
        WaveDefinition(enemies: [EnemySpawn(.skull, count: 15)], delayBeforeWave: 9.0, spawnInterval: 0.8),
        WaveDefinition(enemies: [EnemySpawn(.bear, count: 12), EnemySpawn(.skull, count: 8)], delayBeforeWave: 8.0, spawnInterval: 0.7),
        WaveDefinition(enemies: [EnemySpawn(.shaman, count: 6), EnemySpawn(.gnome, count: 20)], delayBeforeWave: 10.0, spawnInterval: 0.5),
        WaveDefinition(enemies: [EnemySpawn(.lancer, count: 15), EnemySpawn(.bear, count: 10)], delayBeforeWave: 9.0, spawnInterval: 0.6),
        
        // Mid waves - more variety and challenge
        WaveDefinition(enemies: [EnemySpawn(.lizard, count: 10), EnemySpawn(.skull, count: 15)], delayBeforeWave: 10.0, spawnInterval: 0.5),
        WaveDefinition(enemies: [EnemySpawn(.snake, count: 8), EnemySpawn(.spider, count: 12), EnemySpawn(.gnome, count: 10)], delayBeforeWave: 11.0, spawnInterval: 0.4),
        WaveDefinition(enemies: [EnemySpawn(.shaman, count: 8), EnemySpawn(.lancer, count: 12), EnemySpawn(.bear, count: 8)], delayBeforeWave: 12.0, spawnInterval: 0.5),
        WaveDefinition(enemies: [EnemySpawn(.thief, count: 15), EnemySpawn(.skull, count: 10)], delayBeforeWave: 8.0, spawnInterval: 0.3),
        WaveDefinition(enemies: [EnemySpawn(.gnoll, count: 6), EnemySpawn(.lizard, count: 8), EnemySpawn(.gnome, count: 15)], delayBeforeWave: 10.0, spawnInterval: 0.4),
        
        // Late waves - heavy mixed forces
        WaveDefinition(enemies: [EnemySpawn(.bear, count: 20), EnemySpawn(.shaman, count: 10), EnemySpawn(.lancer, count: 15)], delayBeforeWave: 15.0, spawnInterval: 0.4),
        WaveDefinition(enemies: [EnemySpawn(.minotaur, count: 4), EnemySpawn(.skull, count: 20), EnemySpawn(.spider, count: 10)], delayBeforeWave: 12.0, spawnInterval: 0.3),
        WaveDefinition(enemies: [EnemySpawn(.troll, count: 3), EnemySpawn(.gnoll, count: 8), EnemySpawn(.bear, count: 15), EnemySpawn(.shaman, count: 8)], delayBeforeWave: 18.0, spawnInterval: 0.4),
        WaveDefinition(enemies: [EnemySpawn(.panda, count: 6), EnemySpawn(.lizard, count: 12), EnemySpawn(.thief, count: 20), EnemySpawn(.lancer, count: 10)], delayBeforeWave: 15.0, spawnInterval: 0.3),
        
        // Final wave - epic boss rush
        WaveDefinition(enemies: [
            EnemySpawn(.troll, count: 5), 
            EnemySpawn(.minotaur, count: 6), 
            EnemySpawn(.panda, count: 8), 
            EnemySpawn(.shaman, count: 12), 
            EnemySpawn(.bear, count: 25), 
            EnemySpawn(.skull, count: 20)
        ], delayBeforeWave: 25.0, spawnInterval: 0.2)
    ])
}