//
//  Portal.swift
//  RushDefense
//
//  Visual portal object with spawn and idle animations.
//

import Foundation
import SpriteKit

enum PortalTexture: TextureSheetProvider {
    case start
    case idle

    var assetName: String {
        switch self {
        case .start: return "Portal1_Start"
        case .idle: return "Portal1_Idle"
        }
    }
}

/// Portal node that can play a spawn sequence then loop idle.
class Portal: SKNode {
    // MARK: - Configuration
    /// Time per animation frame.
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
        sprite.texture = PortalTexture.start.textures.first
        sprite.size = CGSize(width: 96, height: 96)
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API
    /// Plays the spawn animation once, then loops the idle animation.
    func spawn() {
        sprite.removeAction(forKey: "portal_spawn")
        sprite.removeAction(forKey: "portal_idle")

        let startFrames = PortalTexture.start.textures
        let idleFrames = PortalTexture.idle.textures

        sprite.texture = startFrames.first
        let start = SKAction.animate(with: startFrames, timePerFrame: timePerFrame, resize: false, restore: false)
        let beginIdle = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.sprite.texture = idleFrames.first
            let idle = SKAction.repeatForever(
                SKAction.animate(with: idleFrames, timePerFrame: self.timePerFrame, resize: false, restore: false)
            )
            self.sprite.run(idle, withKey: "portal_idle")
        }
        let sequence = SKAction.sequence([start, beginIdle])
        sprite.run(sequence, withKey: "portal_spawn")
    }
}
