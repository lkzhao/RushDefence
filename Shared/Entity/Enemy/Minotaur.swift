//
//  Minotaur.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//


class Minotaur: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 25 // Slow but powerful - heavy creature
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 200)) // Very high health - tank enemy
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Minotaur"))
        // Minotaur has powerful attacks with good range
        addComponent(MeleeAttackComponent().then({ component in
            component.attackRange = 15
            component.attackDamage = 5 // High damage, high health, slow speed
            component.targetEntityType = [.building]
        }))
    }
}