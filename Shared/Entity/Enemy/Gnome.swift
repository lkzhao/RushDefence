//
//  Gnome.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//


class Gnome: Entity {
    override init() {
        super.init()
        entityType = [.enemy]

        // Set up movement with RouteSeekBehavior for pathfinding, wrapped with pause-when-attacking
        let routeSeek = RouteSeekBehavior()
        let pauseWhenAttacking = PauseWhenAttackingSteeringBehavior(wrapping: routeSeek)
        addComponent(MoveComponent().then({
            $0.speed = 30 // Slower than bear - small legs
            $0.behaviors = [pauseWhenAttacking, AvoidBehavior()]
        }))

        addComponent(HealthComponent(maxHealth: 120)) // Sturdy for their size
        addComponent(IdleAttackRunVisualComponent(texturePrefix: "Enemies/Gnome"))
        // Gnome has strong but slow attacks with medium range
        addComponent(MeleeAttackComponent().then({ component in
            component.attackRange = 9
            component.attackDamage = 1 // Low damage but high health
            component.targetEntityType = [.building]
        }))
    }
}