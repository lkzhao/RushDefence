//
//  GoldMine.swift
//  RushDefense
//
//  Gold mine building that generates gold periodically.
//

class GoldMine: Entity {
    override var gridSize: GridSize { GridSize(w: 2, h: 2) }
    
    override init() {
        super.init()
        entityType = [.building]
        collisionRadius = 16
        addComponent(SpriteComponent(textureName: "Objects/GoldMine_Active", anchorPoint: CGPoint(x: 0.5, y: 0.3)))
    }
}
