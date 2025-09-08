//
//  Altar.swift
//  RushDefense
//
//  Visual altar object with spawn and idle animations.
//

import Foundation
import SpriteKit

enum AltarTexture: TextureSheetProvider {
    case start
    case idle

    var assetName: String {
        switch self {
        case .start: return "Altar_Start"
        case .idle: return "Altar_Idle"
        }
    }
}

/// Altar node that can play a spawn sequence then loop idle.
class Altar: SKNode, Obstacle {
    // MARK: - Configuration
    var timePerFrame: TimeInterval = 0.12

    // MARK: - Private
    private let container = SKNode()
    private let sprite = SKSpriteNode()

    // MARK: - Lifecycle
    override init() {
        super.init()
        addChild(container)
        container.addChild(sprite)

        // Default appearance
        let initialTexture = AltarTexture.start.textures.first
        sprite.texture = initialTexture
        if let t = initialTexture {
            sprite.size = t.size()
        }
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API
    func spawn() {
        sprite.removeAction(forKey: "altar_spawn")
        sprite.removeAction(forKey: "altar_idle")

        let startFrames = AltarTexture.start.textures
        let idleFrames = AltarTexture.idle.textures

        sprite.texture = startFrames.first
        let start = SKAction.animate(with: startFrames, timePerFrame: timePerFrame, resize: false, restore: false)
        let beginIdle = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.sprite.texture = idleFrames.first
            let idle = SKAction.repeatForever(
                SKAction.animate(with: idleFrames, timePerFrame: self.timePerFrame, resize: false, restore: false)
            )
            self.sprite.run(idle, withKey: "altar_idle")
        }
        let sequence = SKAction.sequence([start, beginIdle])
        sprite.run(sequence, withKey: "altar_spawn")
    }

    // MARK: - Obstacle
    var obstacleRect: CGRect {
        CGRect(center: CGPoint(x: 0, y: -10), size: CGSize(width: 20, height: 20))
    }
}
