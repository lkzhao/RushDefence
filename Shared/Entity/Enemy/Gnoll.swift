//
//  Gnoll.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//


class Gnoll: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 40 // Moderate speed for a bone-throwing gnoll
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 85)) // Moderate health
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Gnoll"))
        
        // Gnoll throws bones at enemies at medium range
        addComponent(ProjectileAttackComponent().then({ component in
            component.attackRange = 150
            component.attackDamage = 2 // Moderate damage with bone throwing
            component.targetEntityType = [.building, .ally, .worker]
            component.projectileSpeed = 300
            component.projectileMaxDistance = 170
            component.projectileTexture = "Enemies/Gnoll/Gnoll_Bone"
            component.explosionTexture = "Enemies/Gnoll/Gnoll_Hit"
        }))
    }
}