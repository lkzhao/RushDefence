//
//  IdleAttackRunVisualComponent.swift
//  RushDefense
//
//  Created by Luke Zhao on 9/13/25.
//



class IdleAttackRunVisualComponent: VisualComponent {
    var textureIndex: Int = 0
    var lastTextureUpdateTime: Double = 0
    let timePerFrame: Double = 0.12
    let texturePrefix: String

    enum State {
        case idle, attack, run
        var textureSuffix: String {
            switch self {
            case .idle: return "Idle"
            case .attack: return "Attack"
            case .run: return "Run"
            }
        }
    }

    var state: State = .idle

    init(texturePrefix: String) {
        self.texturePrefix = texturePrefix
        super.init()
        sprite.texture = TextureCache.shared.textures(for: "\(texturePrefix)_Idle").first
        sprite.size = sprite.texture!.size() / 2
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        guard let moveComponent = entity?.component(ofType: MoveComponent.self) else { return }
        guard let attackComponent = entity?.component(ofType: AttackComponent.self) else { return }
        state = attackComponent.lastAttackTime + 1.0 > lastUpdateTime ? .attack : (moveComponent.isMoving ? .run : .idle)
        let textureSuffix = state.textureSuffix
        let frames = TextureCache.shared.textures(for: "\(texturePrefix)_\(textureSuffix)")
        sprite.xScale = moveComponent.direction.x < 0 ? -1 : 1
        if lastUpdateTime > lastTextureUpdateTime + timePerFrame {
            lastTextureUpdateTime = lastUpdateTime
            textureIndex += 1
        }
        textureIndex = textureIndex % frames.count
        sprite.texture = frames[textureIndex]
    }


    override func despawn() {
        guard let agent = entity?.component(ofType: MoveComponent.self) else { return }
        let effectNode = EffectNode(position: agent.position, direction: agent.direction, textureName: "Effects/Explosions", scale: 0.5)
        effectNode.zPosition = 200
        entity?.node.parent?.addChild(effectNode)
        super.despawn()
    }
}
