//
//  Thief.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//


class Thief: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 80 // Very fast - thieves are quick
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 40)) // Low health - glass cannon
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Thief"))
        // Thief has quick strikes with short range but fast attack speed
        addComponent(MeleeAttackComponent().then({ component in
            component.attackRange = 6
            component.attackDamage = 4 // High damage but low health
            component.targetEntityType = [.building]
        }))
    }
}