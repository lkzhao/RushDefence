//
//  TurretVisualComponent.swift
//  RushDefense
//
//  Handles turret visual rotation using 9-frame directional textures.
//  Frames 1-9 represent angles from south facing counter-clockwise to north.
//  Uses horizontal flipping for west-side angles.
//

import SpriteKit

class TurretVisualComponent: VisualComponent {
    private var lastTargetDirection: CGPoint = CGPoint(x: 0, y: -1) // Default facing south
    
    override init() {
        super.init()
        // Start with frame 1 (south-facing)
        updateTexture(for: lastTargetDirection)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        // Get attack direction from AttackComponent
        guard let attackComponent = entity?.component(ofType: AttackComponent.self),
              let target = attackComponent.target else {
            return
        }
        
        let entityPosition = entity?.node.position ?? .zero
        let targetDirection = (target.node.position - entityPosition).normalized()
        
        // Only update if direction changed significantly
        if lastTargetDirection.distance(targetDirection) > 0.1 {
            lastTargetDirection = targetDirection
            updateTexture(for: targetDirection)
        }
    }
    
    private func updateTexture(for direction: CGPoint) {
        let angle = (direction.angle + .pi / 2).wrapAngle
        let textures = TextureCache.shared.textures(for: "Weapons/1")
        var textureIndex = Int(angle / (CGFloat.pi / 8))
        if textureIndex > 8 {
            textureIndex = 8 - (textureIndex - 8)
            sprite.xScale = -1
        } else {
            sprite.xScale = 1
        }
        let texture = textures[textureIndex]
        sprite.texture = texture
        sprite.size = texture.size()
    }
}

