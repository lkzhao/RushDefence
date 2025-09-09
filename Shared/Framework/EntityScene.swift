//
//  EntityScene.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

import SpriteKit

class EntityScene: SKScene {
    private(set) var entities = [Entity]()
    private var lastUpdateTime: TimeInterval = 0

    func addEntity(_ entity: Entity) {
        entities.append(entity)
        entity.didAddToScene(self)
    }

    func removeEntity(_ entity: Entity) {
        if let index = entities.firstIndex(where: { $0 === entity }) {
            entities.remove(at: index)
            entity.node.removeFromParent()
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let deltaTime = currentTime - lastUpdateTime
        for entity in entities {
            entity.update(deltaTime: deltaTime)
        }
        lastUpdateTime = currentTime
    }
}
