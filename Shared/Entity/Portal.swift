//
//  Portal.swift
//  RushDefense
//
//  Visual portal object with spawn and idle animations.
//

class Portal: Entity {
    override init() {
        super.init()
        entityType = [.building]
        collisionRadius = 34
        addComponent(IdleSpawnVisualComponent(idleTexture: "Portal1_Idle",
                                              spawnTexture: "Portal1_Start"))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
