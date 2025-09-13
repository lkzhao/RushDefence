//
//  Turret.swift
//  RushDefense
//
//  Defensive tower that automatically attacks enemies in range.
//

class Turret: Entity {
    static let cost = 100
    override var gridSize: GridSize { GridSize(w: 1, h: 1) }
    let turretType: String
    
    init(turretType: String = "1") {
        self.turretType = turretType
        super.init()
        entityType = [.building, .ally]
        collisionRadius = 20
        addComponent(HealthComponent(maxHealth: 200))
        addComponent(TurretVisualComponent(turretType: turretType))
        addComponent(ProjectileAttackComponent().then({ component in
            component.attackRange = 120
            component.attackDamage = 30
            component.attackInterval = 0.8
            component.targetEntityType = [.enemy]
            component.projectileSpeed = 350
        }))
    }
    
}
