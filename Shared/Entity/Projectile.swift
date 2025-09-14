//
//  Projectile.swift
//  RushDefense
//

import SpriteKit

class Projectile: Entity {
    let projectileComponent: ProjectileComponent

    init(speed: CGFloat, maxDistance: CGFloat, damage: Int, knockback: CGFloat, direction: CGPoint, ownerType: EntityType, projectileTexture: String = "Projectiles/5", explosionTexture: String = "Effects/4_1", projectileScale: CGFloat = 1.0, explosionScale: CGFloat = 1.0) {
        self.projectileComponent = ProjectileComponent(speed: speed, damage: damage, knockback: knockback, ownerType: ownerType, explosionTexture: explosionTexture)
        super.init()
        entityType = [.projectile]
        collisionRadius = 4

        // Movement uses MoveComponent with constant velocity.
        let mover = MoveComponent()
        mover.velocity = direction.normalized() * speed
        mover.speed = speed
        mover.linearDamping = 0
        addComponent(mover)

        projectileComponent.maxDistance = maxDistance
        projectileComponent.explosionScale = explosionScale
        addComponent(projectileComponent)
        let spriteComponent = SpriteComponent(textureName: projectileTexture, autoRotateWithVelocity: true)
        spriteComponent.sprite.setScale(projectileScale)
        addComponent(spriteComponent)
        addComponent(TrailComponent(textureName: projectileTexture))
    }
}
