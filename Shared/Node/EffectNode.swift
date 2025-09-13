//
//  EffectNode.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

class EffectNode: SKNode {
    let sprite = SKSpriteNode(texture: nil)

    /// Creates a directional effect at a world `position` aligned to `direction`.
    init(position: CGPoint, direction: CGPoint, textureName: String, scale: CGFloat = 1.0, anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        super.init()
        self.position = position
        zPosition = 100
        let angle = direction.angle
        let textures = TextureCache.shared.textures(for: textureName)
        sprite.zRotation = angle + .pi
        addChild(sprite)
        let action = SKAction.animate(with: textures, timePerFrame: 0.12, resize: false, restore: false)
        sprite.texture = textures.first
        sprite.size = (textures.first?.size() ?? .zero) * scale
        sprite.anchorPoint = anchorPoint
        sprite.run(action) { [weak self] in
            self?.removeFromParent()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
