//
//  Lancer.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//

class Lancer: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 60  // Faster than Bear (40)
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 75))  // Less health than Bear (100)
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Lancer"))
        // Lancer has longer reach but less damage than Bear
        addComponent(MeleeAttackComponent().then({ component in
            component.attackRange = 15  // Longer reach than Bear (10)
            component.attackDamage = 3  // More damage than Bear (2)
            component.targetEntityType = [.building]
            component.attackInterval = 0.8  // Slower attack speed
        }))
    }
}