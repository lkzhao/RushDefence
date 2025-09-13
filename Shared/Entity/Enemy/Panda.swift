//
//  Panda.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//


class Panda: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 35 // Moderate speed for a chunky panda
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 150)) // High health, tanky panda
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Panda"))
        // Panda has guard abilities and strong attacks
        addComponent(MeleeAttackComponent().then({ component in
            component.attackRange = 10
            component.attackDamage = 3 // Strong but measured attacks
            component.targetEntityType = [.building]
        }))
    }
}