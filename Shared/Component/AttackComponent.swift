//
//  AttackComponent.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

import Foundation

class AttackComponent: Component {
    var attackRange: CGFloat = 150
    var attackDamage: Int = 50
    var attackInterval: TimeInterval = 0.5
    var lastTryAttackTime: TimeInterval = 0
    var lastAttackTime: TimeInterval = -.infinity
    // What types of entities this component can target. Defaults to enemies.
    var targetEntityType: EntityType = [.enemy]
    var target: Entity?
    var knockback: CGFloat = 20 // interpreted as impulse magnitude

    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        if lastUpdateTime - lastTryAttackTime >= attackInterval {
            lastTryAttackTime = lastUpdateTime
            tryAttack()
        }
    }

    func tryAttack() {
        guard let entity = entity else { return }

        if let target,
           target.node.position.distance(entity.node.position) > attackRange ||
           target.healthComponent?.currentHealth ?? 0 <= 0 {
            self.target = nil
        }

        if target == nil {
            guard let all = entity.map?.entities else { return }
            let candidates = all.filter { other in
                // Exclude self and projectiles
                guard other !== entity, !other.entityType.contains(.projectile) else { return false }
                // Must have health and be alive to be targeted
                guard let hp = other.healthComponent, hp.currentHealth > 0 else { return false }
                // Must match one of the target types
                let matchesType = (other.entityType.rawValue & targetEntityType.rawValue) != 0
                guard matchesType else { return false }
                // Check distance
                let distance = entity.node.position.distance(other.node.position)
                return (distance - other.collisionRadius - entity.collisionRadius) <= attackRange
            }.sorted { (a, b) -> Bool in
                let dist1 = entity.node.position.distance(a.node.position)
                let dist2 = entity.node.position.distance(b.node.position)
                return dist1 < dist2
            }
            target = candidates.first
        }

        if let target {
            performAttack(on: target)
        }
    }
    
    // Subclasses should override this method to implement their specific attack behavior
    func performAttack(on target: Entity) {
        // Base implementation does nothing - subclasses should override
    }
}
