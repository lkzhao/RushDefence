//
//  Spider.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//


class Spider: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 50 // Medium speed
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 80)) // Medium health
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Spider"))
        // Spider has web-like attacks with medium range
        addComponent(MeleeAttackComponent().then({ component in
            component.attackRange = 12
            component.attackDamage = 2 // Moderate damage
            component.targetEntityType = [.building]
        }))
    }
}