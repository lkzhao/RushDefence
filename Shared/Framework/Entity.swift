//
//  Entity.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

import SpriteKit

class Entity {
    let node = SKNode()
    weak var scene: EntityScene?
    var entityType: EntityType = []
    var collisionRadius: CGFloat = 8

    private(set) var components: [Component] = []

    // MARK: - Scene lifecycle
    func didAddToScene(_ scene: EntityScene) {
        self.scene = scene
        scene.addChild(node)
    }

    func removeFromScene() {
        node.removeFromParent()
        scene?.removeEntity(self)
    }

    // MARK: - Components
    func addComponent(_ component: Component) {
        components.append(component)
        component.entity = self
        component.didAddToEntity()
    }

    func removeComponent(_ component: Component) {
        if let idx = components.firstIndex(where: { $0 === component }) {
            components[idx].willRemoveFromEntity()
            components[idx].entity = nil
            components.remove(at: idx)
        }
    }

    func component<T: Component>(ofType type: T.Type) -> T? {
        components.first { $0 is T } as? T
    }

    // MARK: - Update
    func update(deltaTime seconds: TimeInterval) {
        for component in components {
            component.update(deltaTime: seconds)
        }
    }
}
