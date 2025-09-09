//
//  ProjectileComponent.swift
//  RushDefense
//

import SpriteKit
import GameplayKit

class ProjectileComponent: GKComponent {
    var speed: CGFloat
    var damage: Int
    var knockback: CGFloat
    var ownerType: EntityType
    var maxDistance: CGFloat = 1000
    private var traveled: CGFloat = 0

    init(speed: CGFloat, damage: Int, knockback: CGFloat, ownerType: EntityType) {
        self.speed = speed
        self.damage = damage
        self.knockback = knockback
        self.ownerType = ownerType
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard seconds > 0, let entity = entity as? NodeEntity,
              let scene = entity.scene else { return }

        // Track distance; MoveComponent integrates position already.
        if let v = entity.moveComponent?.velocity { traveled += v.length * CGFloat(seconds) }
        if traveled >= maxDistance {
            // Range-expire effect at projectile's current position and direction
            let pos = entity.node.position
            let v = entity.moveComponent?.velocity ?? .zero
            let dir = v.length > 0 ? v.normalized() : CGPoint(x: 1, y: 0)
            let effectNode = EffectNode(position: pos, direction: dir)
            scene.addChild(effectNode)
            entity.removeFromScene()
            return
        }

        // Check hit against valid targets.
        let myPos = entity.node.position
        let myRadius = entity.collisionRadius

        for other in scene.entities {
            if other.entityType.contains(.projectile) { continue }
            if !isValidTarget(other) { continue }

            let otherPos = other.node.position
            let offset = otherPos - myPos
            let dist = offset.length
            let otherRadius = other.collisionRadius
            if dist <= myRadius + otherRadius {
                // Apply damage
                if let health = other.component(ofType: HealthComponent.self) {
                    health.takeDamage(damage)
                }
                // Apply knockback along projectile direction
                let v = entity.moveComponent?.velocity ?? .zero
                let dir = v.normalized() * 0.8 + offset.normalized() * 0.2
                other.moveComponent?.applyImpulse(dir * knockback)

                // Impact effect aligned with projectile direction at projectile's hit position
                let effectNode = EffectNode(position: myPos, direction: dir)
                scene.addChild(effectNode)
                entity.removeFromScene()
                break
            }
        }
    }

    private func isValidTarget(_ other: NodeEntity) -> Bool {
        if ownerType.contains(.enemy) {
            return other.entityType.contains(.ally) || other.entityType.contains(.worker) || other.entityType.contains(.building)
        } else {
            // Ally/worker/building projectiles hit enemies
            return other.entityType.contains(.enemy)
        }
    }
}
