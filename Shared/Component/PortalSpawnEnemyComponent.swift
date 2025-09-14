//
//  PortalSpawnEnemyComponent.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

class PortalSpawnEnemyComponent: Component {
    let spawnInterval: TimeInterval
    var timeSinceLastSpawn: TimeInterval = 0
    let enemyFactory: () -> Entity

    init(spawnInterval: TimeInterval, enemyFactory: @escaping () -> Entity) {
        self.spawnInterval = spawnInterval
        self.enemyFactory = enemyFactory
        super.init()
    }


    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        timeSinceLastSpawn += seconds
        if timeSinceLastSpawn >= spawnInterval {
            timeSinceLastSpawn = 0
            spawnEnemy()
        }
    }

    private func spawnEnemy() {
        guard let map = entity?.map else { return }
        guard let altar = map.entities.compactMap({ $0 as? Altar }).first else { return }
        let enemy = enemyFactory()
        
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
}
