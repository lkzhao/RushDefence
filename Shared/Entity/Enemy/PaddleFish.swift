//
//  PaddleFish.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//


class PaddleFish: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 45 // Moderately fast swimmer
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 90)) // Moderate health
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Paddle Fish"))
        // Paddle Fish slaps with its paddle-like appendage
        addComponent(MeleeAttackComponent().then({ component in
            component.attackRange = 11
            component.attackDamage = 2 // Moderate damage
            component.targetEntityType = [.building]
        }))
    }
}