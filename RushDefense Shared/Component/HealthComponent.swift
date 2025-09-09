//
//  HealthComponent.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//



class HealthComponent: GKComponent {
    var maxHealth: Int
    var currentHealth: Int

    init(maxHealth: Int) {
        self.maxHealth = maxHealth
        self.currentHealth = maxHealth
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func takeDamage(_ amount: Int) {
        currentHealth -= amount
        if currentHealth <= 0 {
            currentHealth = 0
            if let enemyVisualComponent = entity?.components.compactMap({ $0 as? EnemyVisualComponent }).first {
                enemyVisualComponent.despawn()
                entity?.moveComponent?.target = nil
            } else if let entity = entity as? NodeEntity {
                entity.removeFromScene()
            }
        }
    }

    func heal(_ amount: Int) {
        currentHealth += amount
        if currentHealth > maxHealth {
            currentHealth = maxHealth
        }
    }
}
