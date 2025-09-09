//
//  EnemyVisualComponent.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/9/25.
//



class EnemyVisualComponent: GKComponent, VisualComponent {
    let sprite = SKSpriteNode()
    var textureIndex: Int = 0
    var lastTextureUpdateTime: Double = 0
    var renderTime: Double = 0
    let timePerFrame: Double = 0.12
    let texturePrefix: String

    init(texturePrefix: String) {
        self.texturePrefix = texturePrefix
        super.init()
        sprite.texture = TextureCache.shared.textures(for: "\(texturePrefix)RunSD").first
        sprite.size = sprite.texture!.size()
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        guard let agent = entity?.component(ofType: MoveComponent.self) else { return }
        let textureSuffix = agent.direction.y < 0 ? "RunSD" : "RunSU"
        let frames = TextureCache.shared.textures(for: "\(texturePrefix)\(textureSuffix)")
        if agent.isMoving {
            sprite.xScale = agent.direction.x < 0 ? -1 : 1
            if renderTime > lastTextureUpdateTime + timePerFrame {
                lastTextureUpdateTime = renderTime
                textureIndex = (textureIndex + 1) % frames.count
            }
            sprite.texture = frames[textureIndex]
        } else {
            sprite.texture = frames.first
            textureIndex = 0
        }
        renderTime += seconds
    }

    override func didAddToEntity() {
        super.didAddToEntity()
        if let entity = entity as? NodeEntity {
            entity.node.addChild(sprite)
        }
    }

    func despawn() {
        guard let agent = entity?.component(ofType: MoveComponent.self) else { return }
        let textureSuffix = agent.direction.y < 0 ? "DeathSD" : "DeathSU"
        let frames = TextureCache.shared.textures(for: "\(texturePrefix)\(textureSuffix)")
        sprite.removeAllActions()
        let death = SKAction.animate(with: frames, timePerFrame: timePerFrame, resize: false, restore: false)
        let remove = SKAction.run {
            (self.entity as? NodeEntity)?.removeFromScene()
        }
        let sequence = SKAction.sequence([death, remove])
        sprite.run(sequence)
    }
}
