//
//  EffectNode.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

class EffectNode: SKNode {
    let sprite = SKSpriteNode(texture: nil)

    init(position: CGPoint, source: CGPoint) {
        super.init()
        let dist = (position - source).length
        let targetPos = (position - source) / dist * (dist - 10) + source
        self.position = targetPos
        zPosition = 100
        let angle = (position - source).angle
        let textures = TextureCache.shared.textures(for: "Effects/4_1")
        sprite.zRotation = angle + .pi
        addChild(sprite)
        let action = SKAction.animate(with: textures, timePerFrame: 0.12, resize: false, restore: false)
        sprite.texture = textures.first
        sprite.size = textures.first?.size() ?? .zero
        sprite.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        sprite.run(action) { [weak self] in
            self?.removeFromParent()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
