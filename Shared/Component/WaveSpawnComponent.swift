//
//  WaveSpawnComponent.swift
//  RushDefense
//
//  Wave-based enemy spawning component to replace PortalSpawnEnemyComponent
//

import Foundation

protocol WaveSpawnDelegate: AnyObject {
    func waveCompleted(waveNumber: Int)
    func allWavesCompleted()
}

class WaveSpawnComponent: Component {
    private let waveConfiguration: LevelWaveConfiguration
    weak var delegate: WaveSpawnDelegate?
    
    private var currentWaveIndex = 0
    private var currentEnemySpawnIndex = 0
    private var enemiesSpawnedInCurrentGroup = 0
    private var timeSinceLastSpawn: TimeInterval = 0
    private var waveDelayRemaining: TimeInterval = 0
    private var isWaitingForNextWave = true
    
    private var isCompleted = false
    
    init(waveConfiguration: LevelWaveConfiguration) {
        self.waveConfiguration = waveConfiguration
        super.init()
    }
    
    override func didAddToEntity() {
        super.didAddToEntity()
        startNextWave()
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard !isCompleted else { return }
        
        if isWaitingForNextWave {
            waveDelayRemaining -= seconds
            if waveDelayRemaining <= 0 {
                isWaitingForNextWave = false
            }
            return
        }
        
        guard currentWaveIndex < waveConfiguration.waves.count else {
            if !isCompleted {
                isCompleted = true
                delegate?.allWavesCompleted()
            }
            return
        }
        
        let currentWave = waveConfiguration.waves[currentWaveIndex]
        
        timeSinceLastSpawn += seconds
        if timeSinceLastSpawn >= currentWave.spawnInterval {
            timeSinceLastSpawn = 0
            spawnNextEnemy()
        }
    }
    
    private func startNextWave() {
        guard currentWaveIndex < waveConfiguration.waves.count else { return }
        
        let wave = waveConfiguration.waves[currentWaveIndex]
        waveDelayRemaining = wave.delayBeforeWave
        isWaitingForNextWave = true
        currentEnemySpawnIndex = 0
        enemiesSpawnedInCurrentGroup = 0
        timeSinceLastSpawn = 0
    }
    
    private func spawnNextEnemy() {
        guard currentWaveIndex < waveConfiguration.waves.count else { return }
        
        let currentWave = waveConfiguration.waves[currentWaveIndex]
        
        guard currentEnemySpawnIndex < currentWave.enemies.count else {
            completeCurrentWave()
            return
        }
        
        let currentEnemySpawn = currentWave.enemies[currentEnemySpawnIndex]
        
        guard enemiesSpawnedInCurrentGroup < currentEnemySpawn.count else {
            currentEnemySpawnIndex += 1
            enemiesSpawnedInCurrentGroup = 0
            return
        }
        
        spawnEnemy(of: currentEnemySpawn.enemyType)
        enemiesSpawnedInCurrentGroup += 1
    }
    
    private func spawnEnemy(of type: EnemyType) {
        guard let map = entity?.map else { return }
        guard let altar = map.entities.compactMap({ $0 as? Altar }).first else { return }
        
        let enemy = EnemyFactory.createEnemy(of: type)
        
        // Add random offset to prevent enemies from spawning in a single line
        let basePosition = entity?.node.position ?? .zero
        let offsetX = Float.random(in: -15...15)
        let offsetY = Float.random(in: -15...15)
        let spawnPosition = CGPoint(x: basePosition.x + CGFloat(offsetX), 
                                   y: basePosition.y + CGFloat(offsetY))
        
        enemy.moveComponent?.position = spawnPosition
        
        // Set up pathfinding target for RouteSeekBehavior
        let altarGridLocation = map.grid(for: altar.node.position)
        if let routeSeek = enemy.moveComponent?.routeSeekBehavior {
            routeSeek.targetLocation = altarGridLocation
        }
        
        // Also set direct target as fallback
        enemy.moveComponent?.target = altar.node.position
        map.addEntity(enemy)
    }
    
    private func completeCurrentWave() {
        delegate?.waveCompleted(waveNumber: currentWaveIndex + 1)
        currentWaveIndex += 1
        
        if currentWaveIndex < waveConfiguration.waves.count {
            startNextWave()
        } else {
            isCompleted = true
            delegate?.allWavesCompleted()
        }
    }
    
    // MARK: - Public Interface
    var currentWave: Int { currentWaveIndex + 1 }
    var totalWaves: Int { waveConfiguration.waves.count }
    var isWaveInProgress: Bool { !isWaitingForNextWave && !isCompleted }
    var timeUntilNextWave: TimeInterval { isWaitingForNextWave ? waveDelayRemaining : 0 }
}