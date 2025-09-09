//
//  AttackComponent.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

import Foundation

class AttackComponent: GKComponent {
    var attackRange: CGFloat = 150
    var attackDamage: Int = 50
    var attackInterval: TimeInterval = 0.5
    var lastAttackTime: TimeInterval = 0
    // What types of entities this component can target. Defaults to enemies.
    var targetEntityType: EntityType = [.enemy]
    var target: NodeEntity?
    var knockback: CGFloat = 20 // interpreted as impulse magnitude
    var projectileSpeed: CGFloat = 400
    var projectileMaxDistance: CGFloat = 1000

    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        lastAttackTime += seconds
        if lastAttackTime >= attackInterval {
            lastAttackTime = 0
            performAttack()
        }
    }

    func performAttack() {
        guard let entity = entity as? NodeEntity,
              let scene = entity.node.scene as? GameScene else { return }

        if let target, target.node.position.distance(entity.node.position) > attackRange || target.healthComponent?.currentHealth ?? 0 <= 0 {
            self.target = nil
        }

        if target == nil {
            let candidates = scene.entities.filter { other in
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
            // Fire a simple projectile toward the current target.
            let toTarget = target.node.position - entity.node.position
            let dir = toTarget.length > 0 ? toTarget / toTarget.length : CGPoint(x: 1, y: 0)
            let projectile = Projectile(speed: projectileSpeed,
                                        maxDistance: projectileMaxDistance,
                                        damage: attackDamage,
                                        knockback: knockback,
                                        direction: dir,
                                        ownerType: entity.entityType)
            projectile.moveComponent?.position = entity.node.position
            scene.addEntity(projectile)
        }
    }
}
