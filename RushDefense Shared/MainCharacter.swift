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
    private var waypoints: [CGPoint] = []
    private var arrivalCompletion: (() -> Void)?
    private var frameIndex: Int = 0
    private var frameTimer: TimeInterval = 0

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

        // No physics body; obstacle avoidance uses custom protocol and GameplayKit
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API
    // Convenience removed: call walkPath([point]) instead of walkTo

    /// Follow a series of waypoints with walking animation.
    /// - Parameters:
    ///   - points: Waypoints in parent coordinates, in order.
    ///   - completion: Called after arriving at the final point.
    func walkPath(_ points: [CGPoint], completion: (() -> Void)? = nil) {
        waypoints = points
        arrivalCompletion = completion
    }

    // MARK: - Facing & Animation

    // MARK: - Per-frame update
    func update(deltaTime dt: TimeInterval) {
        var movedThisFrame = false
        if !waypoints.isEmpty {
            let maxDistance = CGFloat(dt) * max(1, walkSpeed)

            var remaining = maxDistance
            while remaining > 0, let target = waypoints.first {
                let dx = target.x - position.x
                let dy = target.y - position.y
                let dist = hypot(dx, dy)
                if dist <= 0.5 {
                    // Arrived at this waypoint
                    waypoints.removeFirst()
                    continue
                }

                // Update facing continually based on movement vector
                currentAngle = atan2(dy, dx)
                sprite.xScale = (currentAngle + .pi).truncatingRemainder(dividingBy: .pi) < .pi / 2 ? -1 : 1

                if remaining >= dist {
                    position = target
                    waypoints.removeFirst()
                    remaining -= dist
                    movedThisFrame = true
                } else {
                    let ux = dx / dist
                    let uy = dy / dist
                    position.x += ux * remaining
                    position.y += uy * remaining
                    remaining = 0
                    movedThisFrame = true
                }
            }
        }

        if movedThisFrame {
            // Advance manual walk animation frames
            frameTimer += dt
            while frameTimer >= timePerFrame {
                frameTimer -= timePerFrame
                frameIndex = (frameIndex + 1) % 4 // loop 0..3
                let frames = MainCharacterTexture(angle: currentAngle).textures
                if frames.indices.contains(frameIndex) {
                    sprite.texture = frames[frameIndex]
                } else if let first = frames.first {
                    frameIndex = 0
                    sprite.texture = first
                }
            }
        }

        if waypoints.isEmpty {
            // Reset to first frame when not moving
            if movedThisFrame {
                frameIndex = 0
            }
            sprite.texture = MainCharacterTexture(angle: currentAngle).textures.first
            if arrivalCompletion != nil {
                let done = arrivalCompletion
                arrivalCompletion = nil
                done?()
            }
        }
    }
}
