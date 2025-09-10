//
//  Altar.swift
//  RushDefense
//
//  Visual altar object with spawn and idle animations.
//

class Altar: Entity {
    override var gridSize: GridSize { GridSize(w: 2, h: 2) }
    // MARK: - Lifecycle
    override init() {
        super.init()
        entityType = [.building]
        collisionRadius = 16
        addComponent(HealthComponent(maxHealth: 300))
        addComponent(IdleSpawnVisualComponent(idleTexture: "Altar_Idle", spawnTexture: "Altar_Start"))
        visualComponent?.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.3)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
