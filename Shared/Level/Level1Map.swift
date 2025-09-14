//
//  Level1Map.swift
//  RushDefense
//

import SpriteKit

class Level1Map: Map {
    let portal = Portal()
    let altar = Altar()
    let turret = Turret()
    let worker = Worker()
    let goldMine = GoldMine()
    
    private var waveSpawnComponent: WaveSpawnComponent?

    init() {
        super.init(columns: 48, rows: 32)

        // Add entities
        addEntity(worker)
        _ = placeBuilding(portal, at: GridLocation(x: 8, y: 20))
        _ = placeBuilding(altar, at: GridLocation(x: 36, y: 16))
        _ = placeBuilding(turret, at: GridLocation(x: 24, y: 16))
        _ = placeBuilding(goldMine, at: GridLocation(x: 40, y: 14))

        // Spawn visuals and attach wave spawner after a brief delay
        let wait = SKAction.wait(forDuration: 2.0)
        let doSpawn = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.portal.visualComponent?.spawn()
            self.altar.visualComponent?.spawn()
            self.goldMine.visualComponent?.spawn()
            
            let waveSpawnComponent = WaveSpawnComponent(waveConfiguration: .level1)
            waveSpawnComponent.delegate = self
            self.waveSpawnComponent = waveSpawnComponent
            self.portal.addComponent(waveSpawnComponent)
            self.goldMine.addComponent(GoldGenerationComponent())
        }
        node.run(.sequence([wait, doSpawn]))
    }
}

// MARK: - WaveSpawnDelegate
extension Level1Map: WaveSpawnDelegate {
    func waveCompleted(waveNumber: Int) {
        print("Wave \(waveNumber) completed!")
        // Here you could trigger UI updates, sound effects, or other game events
    }
    
    func allWavesCompleted() {
        print("All waves completed! Level 1 finished!")
        // Here you could trigger level completion logic, victory screen, etc.
        delegate?.gameOver()
    }
    
    // MARK: - Wave Info Access
    var currentWave: Int { waveSpawnComponent?.currentWave ?? 1 }
    var totalWaves: Int { waveSpawnComponent?.totalWaves ?? 20 }
    var isWaveInProgress: Bool { waveSpawnComponent?.isWaveInProgress ?? false }
    var timeUntilNextWave: TimeInterval { waveSpawnComponent?.timeUntilNextWave ?? 0 }
}
