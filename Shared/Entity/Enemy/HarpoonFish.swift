//
//  HarpoonFish.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//


class HarpoonFish: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 30 // Slower but precise harpoon thrower
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 95)) // Moderate health
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/HarpoonFish"))
        
        // HarpoonFish throws harpoons at long range with high damage
        addComponent(ProjectileAttackComponent().then({ component in
            component.attackRange = 200 // Long range harpoon throwing
            component.attackDamage = 4 // High damage piercing attacks
            component.targetEntityType = [.building, .ally, .worker]
            component.projectileSpeed = 400 // Fast harpoon
            component.projectileMaxDistance = 220
            component.projectileTexture = "Enemies/Harpoon"
        }))
    }
}
