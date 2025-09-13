//
//  Turtle.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//


class Turtle: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 15 // Very slow turtle
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 250)) // Very high health, defensive
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Turtle"))
        // Turtle has guard abilities and can shell up for defense
        addComponent(MeleeAttackComponent().then({ component in
            component.attackRange = 8
            component.attackDamage = 1 // Low damage but very tanky
            component.targetEntityType = [.building]
        }))
    }
}