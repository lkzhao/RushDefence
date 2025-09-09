//
//  Portal.swift
//  RushDefense
//
//  Visual portal object with spawn and idle animations.
//

class Portal: NodeEntity, Obstacle {
    var visualComponent: IdleSpawnVisualComponent? {
        component(ofType: IdleSpawnVisualComponent.self)
    }

    override init() {
        super.init()
        entityType = [.building]
        collisionRadius = 34
        addComponent(MoveComponent())
        addComponent(IdleSpawnVisualComponent(idleTexture: "Portal1_Idle",
                                              spawnTexture: "Portal1_Start"))
        addComponent(PortalSpawnEnemyComponent(spawnInterval: 1, enemyFactory: {
            Enemy()
        }))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Obstacle
    var obstacleRect: CGRect {
        CGRect(center: CGPoint(x: 0, y: -14), size: CGSize(width: 68, height: 30))
    }
}
