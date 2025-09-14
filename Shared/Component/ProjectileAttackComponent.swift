//
//  ProjectileAttackComponent.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//

import Foundation

class ProjectileAttackComponent: AttackComponent {
    var projectileSpeed: CGFloat = 400
    var projectileMaxDistance: CGFloat = 1000
    var projectileTexture: String = "Projectiles/5"
    var explosionTexture: String = "Effects/4_1"
    var projectileScale: CGFloat = 1.0
    var explosionScale: CGFloat = 1.0

    override init() {
        super.init()
        attackRange = 150
    }

    override func performAttack(on target: Entity) {
        guard let entity = entity else { return }
        
        // Fire a simple projectile toward the current target.
        let origin = entity.node.position
        let targetPos = target.node.position
        let toTarget = targetPos - origin
        let dir = toTarget.length > 0 ? toTarget / toTarget.length : CGPoint(x: 1, y: 0)
        let projectile = Projectile(speed: projectileSpeed,
                                    maxDistance: projectileMaxDistance,
                                    damage: attackDamage,
                                    knockback: knockback,
                                    direction: dir,
                                    ownerType: entity.entityType,
                                    projectileTexture: projectileTexture,
                                    explosionTexture: explosionTexture,
                                    projectileScale: projectileScale,
                                    explosionScale: explosionScale)
        projectile.moveComponent?.position = origin
        entity.map?.addEntity(projectile)
        lastAttackTime = lastTryAttackTime
    }
}