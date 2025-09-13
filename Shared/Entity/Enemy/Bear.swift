//
//  Bear.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//



class Bear: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 40
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 100))
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Bear"))
        // Enemy can attack ally buildings at short range
        addComponent(MeleeAttackComponent().then({ component in
            component.attackRange = 10
            component.attackDamage = 2
            component.targetEntityType = [.building]
        }))
    }
}
