//
//  Boat.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//


class Boat: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 25 // Slow but steady like a boat
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 200)) // High health like a sturdy vessel
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Boat"))
        // Boat rams into buildings with medium range
        addComponent(MeleeAttackComponent().then({ component in
            component.attackRange = 12
            component.attackDamage = 4 // Strong ramming attack
            component.targetEntityType = [.building]
        }))
    }
}