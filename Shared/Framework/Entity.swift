//
//  Entity.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

import SpriteKit

class Entity {
    let node = SKNode()
    weak var map: Map?
    var entityType: EntityType = []
    var collisionRadius: CGFloat = 8
    // Footprint in grid cells when placed on a map.
    // Override in subclasses for buildings larger than 1x1.
    var gridSize: GridSize { GridSize(w: 1, h: 1) }

    private(set) var components: [Component] = []

    // MARK: - Map lifecycle
    func didAddToMap(_ map: Map) {}
    func willRemoveFromMap(_ map: Map) {}
    func removeFromMap() { map?.removeEntity(self) }

    // MARK: - Components
    func addComponent(_ component: Component) {
        components.append(component)
        component.entity = self
        if let visual = component as? VisualComponent {
            node.addChild(visual.sprite)
        }
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
        for component in components { component.update(deltaTime: seconds) }
    }
}
