//
//  NodeEntity.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

class NodeEntity: GKEntity {
    let node = SKNode()
    weak var scene: EntityScene?

    func didAddToScene(_ scene: EntityScene) {
        self.scene = scene
        scene.addChild(node)
    }

    func removeFromScene() {
        node.removeFromParent()
        scene?.removeEntity(self)
    }
}
