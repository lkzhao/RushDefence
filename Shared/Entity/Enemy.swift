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
        addComponent(MoveComponent().then({ $0.speed = 40 }))
        addComponent(HealthComponent(maxHealth: 100))
        addComponent(EnemyVisualComponent(texturePrefix: "Enemies/2/"))
        // Enemy can attack ally buildings at short range
        addComponent(AttackComponent().then({ component in
            component.attackRange = 10
            component.attackDamage = 2
            component.targetEntityType = [.building]
        }))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
