//
//  SteeringBehavior.swift
//  RushDefense
//
//  Protocol and concrete steering behaviors used by MoveComponent.
//

import CoreGraphics
import SpriteKit

protocol SteeringBehavior {
    /// Compute steering force in scene units (points * mass / s^2).
    /// The implementer may use properties on `component` such as position,
    /// velocity, target, movementForce, and arrivalRadius.
    func computeForce(for component: MoveComponent, dt: CGFloat) -> CGPoint
}

/// Seek with ease-in arrival: scales force by distance within `arrivalRadius`
/// for smooth stops near `target`.
class SeekBehavior: SteeringBehavior {
    func computeForce(for component: MoveComponent, dt: CGFloat) -> CGPoint {
        guard let target = component.target, target != component.position else { return .zero }
        let toTarget = target - component.position
        let dist = toTarget.length
        if dist <= 0 { return .zero }
        let dir = toTarget / dist
        let factor = min(1, dist / max(0.0001, component.arrivalRadius))
        return dir * (component.movementForce * factor)
    }
}

/// Placeholder: returns zero until obstacle data is available.
class AvoidBehavior: SteeringBehavior {
    let strength: CGFloat

    init(strength: CGFloat = 800) {
        self.strength = strength
    }

    func computeForce(for component: MoveComponent, dt: CGFloat) -> CGPoint {
        guard let selfEntity = component.entity as? NodeEntity,
              let scene = selfEntity.scene else { return .zero }

        // Only enemies avoid, and only from buildings and workers.
        guard selfEntity.entityType.contains(.enemy) else { return .zero }

        let myPos = component.position
        var force = CGPoint.zero
        let selfRadius = selfEntity.collisionRadius

        for other in scene.entities {
            if other === selfEntity { continue }
            let otherType = other.entityType

            let shouldAvoid = otherType.contains(.building) || otherType.contains(.worker) || otherType.contains(.enemy)
            if !shouldAvoid { continue }

            let otherPos = other.node.position
            let offset = myPos - otherPos
            let dist = offset.length
            if dist <= 0 { continue }

            // Use target's fixed collision radius directly.
            let otherRadius = other.collisionRadius
            let desired = selfRadius + otherRadius
            let penetration = desired - dist
            if penetration <= 0 { continue }

            let invDist = 1 / dist
            let dir = offset * invDist
            let factor = penetration / max(desired, .leastNonzeroMagnitude)
            force += dir * (strength * factor)
        }
        return force
    }
}
