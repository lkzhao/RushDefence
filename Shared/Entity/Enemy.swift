//
//  Enemy.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

class Enemy: Entity {

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
        addComponent(EnemyVisualComponent(texturePrefix: "Enemies/2/"))
        // Enemy can attack ally buildings at short range
        addComponent(AttackComponent().then({ component in
            component.attackRange = 10
            component.attackDamage = 2
            component.targetEntityType = [.building]
        }))
    }
    
    var routeSeekBehavior: RouteSeekBehavior? {
        return moveComponent?.behaviors.compactMap { $0 as? RouteSeekBehavior }.first
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
