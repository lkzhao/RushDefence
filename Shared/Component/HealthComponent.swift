//
//  HealthComponent.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

class HealthComponent: Component {
    var maxHealth: Int
    var currentHealth: Int
    private let healthBar = HealthBarNode()

    init(maxHealth: Int) {
        self.maxHealth = maxHealth
        self.currentHealth = maxHealth
        super.init()
    }

    override func didAddToEntity() {
        super.didAddToEntity()
        if let entity = entity {
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
            if let visual = entity?.components.compactMap({ $0 as? VisualComponent }).first {
                visual.despawn()
                entity?.moveComponent?.target = nil
            } else if let entity = entity {
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
        guard let entity = entity else { return }
        let frame = entity.node.calculateAccumulatedFrame()
        let offsetY = frame.height / 2 - 8
        healthBar.position = CGPoint(x: 0, y: offsetY)
    }
}

extension Entity { var healthComponent: HealthComponent? { component(ofType: HealthComponent.self) } }
