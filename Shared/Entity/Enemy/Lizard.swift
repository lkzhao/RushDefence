//
//  Lizard.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//


class Lizard: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 50 // Fast and agile like a lizard
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 60)) // Low health but fast
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Lizard"))
        // Quick striking attacks
        addComponent(MeleeAttackComponent().then({ component in
            component.attackRange = 8
            component.attackDamage = 3 // Quick strikes
            component.targetEntityType = [.building]
        }))
    }
}