//
//  SpriteComponent.swift
//  RushDefense
//

import SpriteKit

class SpriteComponent: Component {
    let sprite = SKSpriteNode()
    let autoRotateWithVelocity: Bool

    init(textureName: String, anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5), autoRotateWithVelocity: Bool = false) {
        self.autoRotateWithVelocity = autoRotateWithVelocity
        super.init()
        let tex = TextureCache.shared.textures(for: textureName).first
        sprite.texture = tex
        sprite.size = tex?.size() ?? .zero
        sprite.anchorPoint = anchorPoint
    }

    override func didAddToEntity() {
        super.didAddToEntity()
        entity?.node.addChild(sprite)
    }

    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        guard autoRotateWithVelocity,
              let v = entity?.component(ofType: MoveComponent.self)?.velocity else { return }
        if v.length > 0 {
            sprite.zRotation = atan2(v.y, v.x) + .pi / 2
        }
    }
}
