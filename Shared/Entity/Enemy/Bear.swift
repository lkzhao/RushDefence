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

        // Set up movement with RouteSeekBehavior for pathfinding
        let routeSeek = RouteSeekBehavior()
        addComponent(MoveComponent().then({
            $0.speed = 40
            $0.behaviors = [routeSeek, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 100))
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Bear"))
        // Enemy can attack ally buildings at short range
        addComponent(AttackComponent().then({ component in
            component.attackRange = 10
            component.attackDamage = 2
            component.targetEntityType = [.building]
        }))
    }
}
