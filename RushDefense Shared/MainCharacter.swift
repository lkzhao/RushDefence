//
//  MainCharacter.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/7/25.
//

import Foundation
import SpriteKit

enum MainCharacterTexture: TextureSheetProvider {
    case walk1, walk2, walk3

    var assetName: String {
        switch self {
        case .walk1: return "Walk1"
        case .walk2: return "Walk2"
        case .walk3: return "Walk3"
        }
    }

    init(angle: CGFloat) {
        let range = CGFloat.pi / 8
        let slot = ((angle + .pi) / range).rounded(.toNearestOrAwayFromZero)
        self = switch slot {
        case 1, 3, 5, 7, 9, 11, 13, 15:
            .walk2
        case 2, 6, 10, 14:
            .walk3
        default:
            .walk1
        }
    }
}

/// Main controllable character. Renders as a child `SKSpriteNode`
class MainCharacter: SKNode {
    // MARK: - Configuration
    /// Movement speed in points per second.
    var walkSpeed: CGFloat = 100
    /// Time per animation frame.
    var timePerFrame: TimeInterval = 0.12

    // MARK: - Private
    private let container = SKNode()
    private let sprite = SKSpriteNode()
    private var currentAngle: CGFloat = 0 // Radians

    // MARK: - Lifecycle
    override init() {
        super.init()
        addChild(container)
        container.addChild(sprite)
        let initialTexture = MainCharacterTexture.walk1.textures.first
        sprite.texture = initialTexture
        if let t = initialTexture {
            sprite.size = t.size()
        }
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        // Physics: circle with diameter = 2/3 of texture width
        if let w = initialTexture?.size().width {
            let radius = (w * (2.0 / 3.0)) * 0.5
            self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
            self.physicsBody?.isDynamic = true
            self.physicsBody?.affectedByGravity = false
            self.physicsBody?.allowsRotation = false
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API
    /// Move to a location with walking animation. Animation frames are selected
    /// based on the movement angle and rotated in 90° steps to match facing.
    /// - Parameters:
    ///   - location: Target position in parent coordinates.
    ///   - completion: Called after arriving.
    func walkTo(_ location: CGPoint, completion: (() -> Void)? = nil) {
        let delta = CGVector(dx: location.x - position.x, dy: location.y - position.y)
        let distance = hypot(delta.dx, delta.dy)
        guard distance > 0.5 else { completion?(); return }

        currentAngle = atan2(delta.dy, delta.dx)
        print(currentAngle, MainCharacterTexture(angle: currentAngle))
        sprite.xScale = (currentAngle + .pi).truncatingRemainder(dividingBy: .pi) < .pi / 2 ? -1 : 1

        let duration = TimeInterval(distance / max(1, walkSpeed))
        let move = SKAction.move(to: location, duration: duration)
        startWalkAnimation()

        let finish = SKAction.run { [weak self] in
            self?.stopWalkingAnimation()
            completion?()
        }
        let seq = SKAction.sequence([move, finish])
        run(seq, withKey: "move")
    }

    /// Follow a series of waypoints with walking animation.
    /// - Parameters:
    ///   - points: Waypoints in parent coordinates, in order.
    ///   - completion: Called after arriving at the final point.
    func walkPath(_ points: [CGPoint], completion: (() -> Void)? = nil) {
        guard !points.isEmpty else { completion?(); return }
        removeAction(forKey: "move")

        var actions: [SKAction] = []
        var last = position
        for p in points {
            let delta = CGVector(dx: p.x - last.x, dy: p.y - last.y)
            let distance = hypot(delta.dx, delta.dy)
            guard distance > 0.5 else { continue }
            let angle = atan2(delta.dy, delta.dx)
            // Update facing and restart walking frames for this segment
            actions.append(SKAction.run { [weak self] in
                guard let self = self else { return }
                self.currentAngle = angle
                self.sprite.xScale = (angle + .pi).truncatingRemainder(dividingBy: .pi) < .pi / 2 ? -1 : 1
                self.startWalkAnimation()
            })
            let duration = TimeInterval(distance / max(1, walkSpeed))
            actions.append(SKAction.move(to: p, duration: duration))
            last = p
        }

        guard !actions.isEmpty else { completion?(); return }

        let finish = SKAction.run { [weak self] in
            self?.stopWalkingAnimation()
            completion?()
        }
        let seq = SKAction.sequence(actions + [finish])
        run(seq, withKey: "move")
    }

    /// Immediately stops movement and animation.
    func stop() {
        removeAction(forKey: "move")
        stopWalkingAnimation()
    }

    // MARK: - Facing & Animation
    private func startWalkAnimation() {
        sprite.removeAction(forKey: "walkAnim")
        let frames = MainCharacterTexture(angle: currentAngle).textures
        sprite.texture = frames.first
        let animate = SKAction.animate(with: frames, timePerFrame: timePerFrame, resize: false, restore: false)
        let loop = SKAction.repeatForever(animate)
        sprite.run(loop, withKey: "walkAnim")
    }

    private func stopWalkingAnimation() {
        sprite.removeAction(forKey: "walkAnim")
        sprite.texture = MainCharacterTexture(angle: currentAngle).textures.first
    }
}
