//
//  TrailComponent.swift
//  RushDefense
//

import SpriteKit

class TrailComponent: Component {
    var spawnInterval: TimeInterval = 0.04
    var lifetime: TimeInterval = 0.4
    var startAlpha: CGFloat = 0.6
    var endAlpha: CGFloat = 0.0
    var startScale: CGFloat = 0.8
    var endScale: CGFloat = 0.2
    var color: SKColor? = nil
    var zOffset: CGFloat = -0.001

    private var timeSinceLastSpawn: TimeInterval = 0
    private let texture: SKTexture?

    init(textureName: String) {
        self.texture = TextureCache.shared.textures(for: textureName).first
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        timeSinceLastSpawn += seconds
        guard timeSinceLastSpawn >= spawnInterval else { return }
        timeSinceLastSpawn = 0

        guard let entity = entity,
              let parent = entity.node.parent else { return }

        let node = SKSpriteNode(texture: texture)
        node.position = entity.node.position
        node.zPosition = entity.node.zPosition + zOffset
        node.alpha = startAlpha
        node.setScale(startScale)
        if let color { node.color = color; node.colorBlendFactor = 1 }
        parent.addChild(node)

        let fade = SKAction.fadeAlpha(to: endAlpha, duration: lifetime)
        let scale = SKAction.scale(to: endScale, duration: lifetime)
        let group = SKAction.group([fade, scale])
        node.run(group) { [weak node] in node?.removeFromParent() }
    }
}
