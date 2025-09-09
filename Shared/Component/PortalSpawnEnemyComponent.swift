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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        guard let scene = entity?.node.scene as? GameScene else { return }
        let enemy = enemyFactory()
        enemy.moveComponent?.position = entity?.node.position ?? .zero
        enemy.moveComponent?.target = scene.altar.node.position
        scene.addEntity(enemy)
    }
}
