//
//  MoveComponent.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//



class MoveComponent: GKComponent {
    var speed: CGFloat = 80
    var direction: CGPoint = CGPoint(x: 0, y: -1)
    var target: CGPoint?

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
        guard let target, target != position, seconds > 0 else { return }
        let maxDistance = seconds * speed
        let toTarget = target - position
        let dist = toTarget.length
        if dist < 1 {
            position = target
        } else {
            let direction = toTarget / dist
            let travel = min(dist, maxDistance)
            position += direction * travel
            self.direction = direction
        }
    }
}

extension GKEntity {
    var moveComponent: MoveComponent? {
        component(ofType: MoveComponent.self)
    }
}
