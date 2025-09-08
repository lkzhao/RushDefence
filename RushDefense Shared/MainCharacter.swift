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
        sprite.texture = MainCharacterTexture.walk1.textures.first
        sprite.size = CGSize(width: 48, height: 48)
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
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
