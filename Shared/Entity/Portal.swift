//
//  Portal.swift
//  RushDefense
//
//  Visual portal object with spawn and idle animations.
//

class Portal: Entity {
    override var gridSize: GridSize { GridSize(w: 3, h: 3) }
    override init() {
        super.init()
        entityType = [.building]
        collisionRadius = 34
        addComponent(IdleSpawnVisualComponent(idleTexture: "Objects/Portal1_Idle",
                                              spawnTexture: "Objects/Portal1_Start"))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
