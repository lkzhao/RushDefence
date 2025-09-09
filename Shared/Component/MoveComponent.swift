//
//  MoveComponent.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//



class MoveComponent: GKComponent {
    var speed: CGFloat = 80 // treated as max speed (pts/s)
    var direction: CGPoint = CGPoint(x: 0, y: -1)
    var target: CGPoint?
    var mass: CGFloat = 1.0
    var velocity: CGPoint = .zero
    var linearDamping: CGFloat = 6.0 // per second, 0 = no damping
    var velocityEpsilon: CGFloat = 1e-2
    var movementForce: CGFloat = 400 // continuous force magnitude toward target (N-like in pts*mass/s^2)
    var arrivalRadius: CGFloat = 4.0
    var arrivalSnapRadius: CGFloat = 1.0
    var behaviors: [SteeringBehavior] = [SeekBehavior(), AvoidBehavior()]

    var position: CGPoint {
        get {
            if let entity = entity as? NodeEntity {
                return entity.node.position
            }
            return .zero
        }
        set {
            if let entity = entity as? NodeEntity {
                entity.node.position = newValue
                entity.node.zPosition = 3 - newValue.y / (entity.node.scene?.size.height ?? 100)
            }
        }
    }

    var isMoving: Bool {
        target != nil && position != target
    }

    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard seconds > 0 else { return }
        let dt = CGFloat(seconds)

        // 1) Arrival snap check before composing forces
        var force: CGPoint = .zero
        if let target, target != position {
            let toTarget = target - position
            let dist = toTarget.length
            if dist < arrivalSnapRadius {
                // Snap to target and stop when extremely close.
                position = target
                velocity = .zero
            }
        }

        // 2) Compose steering forces via behaviors
        for behavior in behaviors {
            force += behavior.computeForce(for: self, dt: dt)
        }
        if force.length > 0 {
            self.direction = force.normalized()
        }

        // 3) Integrate acceleration into velocity
        if mass > 0 {
            let accel = force / mass
            velocity += accel * dt
        }

        // 4) Apply damping and clamp speed
        if linearDamping > 0 {
            let factor = max(0, 1 - linearDamping * dt)
            velocity = velocity * factor
            if velocity.length < velocityEpsilon { velocity = .zero }
        }
        velocity = velocity.clampedMagnitude(to: speed)

        // 5) Integrate velocity into position
        if velocity.x != 0 || velocity.y != 0 {
            position += velocity * dt
        }

        // 6) Final facing: follow velocity if no explicit steering this frame
        if force == .zero && velocity.length > 0 {
            self.direction = velocity.normalized()
        }
    }

    // Steering behavior methods removed in favor of protocol-based behaviors.

    // MARK: - Forces
    /// Adds an instantaneous change in momentum, modifying velocity by `impulse / mass`.
    func applyImpulse(_ impulse: CGPoint) {
        guard mass > 0 else { return }
        velocity += impulse / mass
    }
}

extension GKEntity {
    var moveComponent: MoveComponent? {
        component(ofType: MoveComponent.self)
    }
}
