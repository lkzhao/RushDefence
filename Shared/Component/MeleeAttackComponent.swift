//
//  MeleeAttackComponent.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//

import Foundation

class MeleeAttackComponent: AttackComponent {
    
    override init() {
        super.init()
        attackRange = 50
    }

    override func performAttack(on target: Entity) {
        guard let entity = entity else { return }
        
        // Direct melee attack - apply damage and knockback immediately
        target.healthComponent?.takeDamage(attackDamage)
        
        // Apply knockback using the same method as ProjectileComponent
        if let targetMoveComponent = target.moveComponent {
            let origin = entity.node.position
            let targetPos = target.node.position
            let toTarget = targetPos - origin
            let dir = toTarget.length > 0 ? toTarget / toTarget.length : CGPoint(x: 1, y: 0)
            targetMoveComponent.applyImpulse(dir * knockback)
        }
        
        lastAttackTime = lastTryAttackTime
    }
}