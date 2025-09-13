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

    init() {
        super.init(columns: 48, rows: 32)

        // Add entities
        addEntity(worker)
        _ = placeBuilding(portal, at: GridLocation(x: 8, y: 20))
        _ = placeBuilding(altar, at: GridLocation(x: 36, y: 16))
        _ = placeBuilding(turret, at: GridLocation(x: 24, y: 16))

        // Spawn visuals and attach spawner after a brief delay
        let wait = SKAction.wait(forDuration: 2.0)
        let doSpawn = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.portal.visualComponent?.spawn()
            self.altar.visualComponent?.spawn()
            self.portal.addComponent(PortalSpawnEnemyComponent(spawnInterval: 1, enemyFactory: { Enemy() }))
        }
        node.run(.sequence([wait, doSpawn]))
    }
}
