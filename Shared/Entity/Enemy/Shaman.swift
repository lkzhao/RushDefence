//
//  Shaman.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//


class Shaman: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 35
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 80))
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Shaman"))
        
        // Enemy can attack ally buildings and units at long range with projectiles
        addComponent(ProjectileAttackComponent().then({ component in
            component.attackRange = 180
            component.attackDamage = 3
            component.targetEntityType = [.building, .ally, .worker]
            component.projectileSpeed = 350
            component.projectileMaxDistance = 200
            component.projectileTexture = "Enemies/Shaman_Projectile"
            component.explosionTexture = "Enemies/Shaman_Explosion"
            component.projectileScale = 0.5
            component.explosionScale = 0.5
        }))
    }
}
