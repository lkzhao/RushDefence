//
//  AttackComponent.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

import Foundation

class AttackComponent: GKComponent {
    var attackRange: CGFloat = 50
    var attackDamage: Int = 50
    var attackInterval: TimeInterval = 0.5
    var lastAttackTime: TimeInterval = 0
    var target: Enemy?
    var knockback: CGFloat = 20 // interpreted as impulse magnitude

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

        if let target, target.node.position.distance(entity.node.position) > attackRange {
            self.target = nil
        }

        if target == nil {
            let enemiesInRange = scene.entities.compactMap { $0 as? Enemy }.filter { enemy in
                let distance = entity.node.position.distance(enemy.node.position)
                return distance <= attackRange
            }.sorted { (enemy1, enemy2) -> Bool in
                let dist1 = entity.node.position.distance(enemy1.node.position)
                let dist2 = entity.node.position.distance(enemy2.node.position)
                return dist1 < dist2
            }
            target = enemiesInRange.first
        }

        if let target {
            // Apply damage and a simple knockback force away from the attacker.
            target.healthComponent.takeDamage(attackDamage)
            let effectNode = EffectNode(position: target.node.position, source: entity.node.position)
            scene.addChild(effectNode)

            let toTarget = target.node.position - entity.node.position
            let dist = toTarget.length
            if dist > 0 {
                let dir = toTarget / dist
                target.moveComponent?.applyImpulse(dir * knockback)
            }

            if target.healthComponent.currentHealth <= 0 {
                self.target = nil
            }
        }
    }
}
