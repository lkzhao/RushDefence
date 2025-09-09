//
//  EntityScene.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//




class EntityScene: SKScene {
    var entities = [NodeEntity]()
    private var lastUpdateTime: TimeInterval = 0

    func addEntity(_ entity: NodeEntity) {
        entities.append(entity)
        entity.didAddToScene(self)
    }

    func removeEntity(_ entity: NodeEntity) {
        if let index = entities.firstIndex(of: entity) {
            entities.remove(at: index)
            entity.removeFromScene()
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