//
//  Altar.swift
//  RushDefense
//
//  Visual altar object with spawn and idle animations.
//

class Altar: NodeEntity, Obstacle {
    var visualComponent: IdleSpawnVisualComponent? {
        component(ofType: IdleSpawnVisualComponent.self)
    }

    // MARK: - Lifecycle
    override init() {
        super.init()
        addComponent(MoveComponent())
        addComponent(IdleSpawnVisualComponent(idleTexture: "Altar_Idle", spawnTexture: "Altar_Start"))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Obstacle
    var obstacleRect: CGRect {
        CGRect(center: CGPoint(x: 0, y: -10), size: CGSize(width: 20, height: 20))
    }
}
