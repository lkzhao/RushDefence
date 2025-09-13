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

/// Avoids other entities based on collision radius.
class AvoidBehavior: SteeringBehavior {
    let strength: CGFloat

    init(strength: CGFloat = 800) {
        self.strength = strength
    }

    func computeForce(for component: MoveComponent, dt: CGFloat) -> CGPoint {
        guard let selfEntity = component.entity else { return .zero }

        // Only enemies avoid, and only from buildings and workers.
        guard selfEntity.entityType.contains(.enemy) else { return .zero }

        let myPos = component.position
        var force = CGPoint.zero
        let selfRadius = selfEntity.collisionRadius

        guard let all = selfEntity.map?.entities else { return .zero }
        for other in all {
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

/// Flow field-based pathfinding behavior that avoids buildings using pre-computed vector fields
class RouteSeekBehavior: SteeringBehavior {
    var targetLocation: GridLocation?
    var fallbackBehavior: SeekBehavior = SeekBehavior()
    
    func computeForce(for component: MoveComponent, dt: CGFloat) -> CGPoint {
        guard let map = component.entity?.map,
              let targetLocation = targetLocation else {
            // Fallback to direct seek when no map or target
            return fallbackBehavior.computeForce(for: component, dt: dt)
        }
        
        // Get flow field for target
        guard let flowField = map.flowFieldManager.getFlowField(to: targetLocation) else {
            // Fallback if flow field generation fails
            return fallbackBehavior.computeForce(for: component, dt: dt)
        }
        
        let currentPos = component.position
        let targetPoint = map.centerPointFor(location: targetLocation)
        
        // Check if we're close enough to target for direct arrival behavior
        let distanceToTarget = (targetPoint - currentPos).length
        if distanceToTarget <= component.arrivalRadius {
            // Use direct seek for final approach
            let originalTarget = component.target
            component.target = targetPoint
            let arrivalForce = fallbackBehavior.computeForce(for: component, dt: dt)
            component.target = originalTarget
            return arrivalForce
        }
        
        // Sample flow field direction at current position
        let flowDirection = flowField.getDirection(at: currentPos, cellSize: map.cellSize)
        
        // Check if flow field gives valid direction
        guard flowDirection.length > 0 else {
            // Fallback to direct seek if flow field doesn't provide direction
            return fallbackBehavior.computeForce(for: component, dt: dt)
        }
        
        // Apply movement force in flow field direction
        let normalizedDirection = flowDirection.normalized()
        return normalizedDirection * component.movementForce
    }
}

/// Pauses movement when the entity is actively attacking a target.
/// Wraps another steering behavior and returns zero force when attacking.
class PauseWhenAttackingSteeringBehavior: SteeringBehavior {
    let wrappedBehavior: SteeringBehavior
    
    init(wrapping behavior: SteeringBehavior) {
        self.wrappedBehavior = behavior
    }
    
    func computeForce(for component: MoveComponent, dt: CGFloat) -> CGPoint {
        guard let entity = component.entity,
              let attackComponent = entity.component(ofType: AttackComponent.self) else {
            // No attack component, delegate to wrapped behavior
            return wrappedBehavior.computeForce(for: component, dt: dt)
        }
        
        // If we have a target, pause movement (AttackComponent handles target validation)
        if attackComponent.target != nil {
            return .zero
        }
        
        // Not attacking, delegate to wrapped behavior
        return wrappedBehavior.computeForce(for: component, dt: dt)
    }
}

extension MoveComponent {
    var routeSeekBehavior: RouteSeekBehavior? {
        behaviors.lazy.compactMap { $0 as? RouteSeekBehavior }.first
    }
}
