//
//  NodeEntity.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

class NodeEntity: GKEntity {
    let node = SKNode()
    weak var scene: EntityScene?
    var entityType: EntityType = []
    var collisionRadius: CGFloat = 8

    func didAddToScene(_ scene: EntityScene) {
        self.scene = scene
        scene.addChild(node)
    }

    func removeFromScene() {
        node.removeFromParent()
        scene?.removeEntity(self)
    }

    // collisionRadius is set per-entity and used directly for interactions.
}
