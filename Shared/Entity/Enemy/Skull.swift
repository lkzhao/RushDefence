//
//  Skull.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//


class Skull: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 55 // Fast floating skull
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 70)) // Fragile but fast undead
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Skull"))
        // Skull has guard abilities and quick attacks
        addComponent(MeleeAttackComponent().then({ component in
            component.attackRange = 9
            component.attackDamage = 2 // Quick strikes
            component.targetEntityType = [.building]
        }))
    }
}