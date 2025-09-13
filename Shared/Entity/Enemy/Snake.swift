//
//  Snake.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//


class Snake: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 60 // Faster than bear
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 60)) // Less health than bear
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Snake"))
        // Snake has quick, poison-like attacks with shorter range
        addComponent(MeleeAttackComponent().then({ component in
            component.attackRange = 8
            component.attackDamage = 3 // Higher damage but less health
            component.targetEntityType = [.building]
        }))
    }
}