//
//  Troll.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//


class Troll: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 20 // Slow but powerful troll
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 300)) // Very high health boss-like enemy
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Troll"))
        // Troll has devastating club attacks with windup and recovery
        addComponent(MeleeAttackComponent().then({ component in
            component.attackRange = 15 // Long reach with club
            component.attackDamage = 8 // Very high damage
            component.targetEntityType = [.building]
        }))
    }
}