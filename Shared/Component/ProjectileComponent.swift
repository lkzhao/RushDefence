//
//  ProjectileComponent.swift
//  RushDefense
//

import SpriteKit

class ProjectileComponent: Component {
    var speed: CGFloat
    var damage: Int
    var knockback: CGFloat
    var ownerType: EntityType
    var maxDistance: CGFloat = 1000
    var explosionTexture: String
    var explosionScale: CGFloat = 1.0
    private var traveled: CGFloat = 0

    init(speed: CGFloat, damage: Int, knockback: CGFloat, ownerType: EntityType, explosionTexture: String = "Effects/4_1") {
        self.speed = speed
        self.damage = damage
        self.knockback = knockback
        self.ownerType = ownerType
        self.explosionTexture = explosionTexture
        super.init()
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard seconds > 0, let entity = entity else { return }

        // Track distance; MoveComponent integrates position already.
        if let v = entity.moveComponent?.velocity { traveled += v.length * CGFloat(seconds) }
        if traveled >= maxDistance {
            // Range-expire effect at projectile's current position and direction
            let pos = entity.node.position
            let v = entity.moveComponent?.velocity ?? .zero
            let dir = v.length > 0 ? v.normalized() : CGPoint(x: 1, y: 0)
            let effectNode = EffectNode(position: pos, direction: dir, textureName: explosionTexture, scale: explosionScale, anchorPoint: CGPoint(x: 0.0, y: 0.5))
            entity.map?.node.addChild(effectNode)
            entity.removeFromMap()
            return
        }

        // Check hit against valid targets.
        let myPos = entity.node.position
        let myRadius = entity.collisionRadius

        guard let all = entity.map?.entities else { return }
        for other in all {
            if other.entityType.contains(.projectile) { continue }
            if !isValidTarget(other) { continue }

            // Same parent => same coordinate space
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
                let effectNode = EffectNode(position: myPos, direction: dir, textureName: explosionTexture, scale: explosionScale, anchorPoint: CGPoint(x: 0.0, y: 0.5))
                entity.map?.node.addChild(effectNode)
                entity.removeFromMap()
                break
            }
        }
    }

    private func isValidTarget(_ other: Entity) -> Bool {
        guard other.healthComponent?.currentHealth ?? 0 > 0 else { return false }
        if ownerType.contains(.enemy) {
            return other.entityType.contains(.ally) || other.entityType.contains(.worker) || other.entityType.contains(.building)
        } else {
            // Ally/worker/building projectiles hit enemies
            return other.entityType.contains(.enemy)
        }
    }
}
