//
//  HealthComponent.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//



class HealthComponent: GKComponent {
    var maxHealth: Int
    var currentHealth: Int
    private let healthBar = HealthBarNode()

    init(maxHealth: Int) {
        self.maxHealth = maxHealth
        self.currentHealth = maxHealth
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didAddToEntity() {
        super.didAddToEntity()
        if let entity = entity as? NodeEntity {
            entity.node.addChild(healthBar)
            updateHealthBarPosition()
            updateHealthBarProgress()
        }
    }

    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        // Reposition in case the visual sprite size changes or animates.
        updateHealthBarPosition()
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
        updateHealthBarProgress()
    }

    func heal(_ amount: Int) {
        currentHealth += amount
        if currentHealth > maxHealth {
            currentHealth = maxHealth
        }
        updateHealthBarProgress()
    }

    private func updateHealthBarProgress() {
        let maxH = max(1, maxHealth)
        healthBar.progress = CGFloat(currentHealth) / CGFloat(maxH)
    }

    private func updateHealthBarPosition() {
        guard let entity = entity as? NodeEntity else { return }
        let frame = entity.node.calculateAccumulatedFrame()
        let offsetY = frame.height / 2 - 8
        healthBar.position = CGPoint(x: 0, y: offsetY)
    }
}

extension GKEntity {
    var healthComponent: HealthComponent? {
        component(ofType: HealthComponent.self)
    }
}
