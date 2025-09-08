//
//  WorkerVisualComponent.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

enum WorkerTexture: TextureSheetProvider {
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

class WorkerVisualComponent: GKComponent {
    let sprite = SKSpriteNode()
    var textureIndex: Int = 0
    var lastTextureUpdateTime: Double = 0
    var renderTime: Double = 0
    let timePerFrame: Double = 0.12

    override init() {
        super.init()
        sprite.texture = WorkerTexture.walk1.textures.first
        sprite.size = sprite.texture!.size()
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let agent = entity?.component(ofType: MoveComponent.self) else { return }
        if agent.isMoving {
            let angle = agent.rotation
            sprite.xScale = (angle + .pi).truncatingRemainder(dividingBy: .pi) < .pi / 2 ? -1 : 1
            let texture = WorkerTexture(angle: CGFloat(angle))
            let frames = texture.textures
            if renderTime > lastTextureUpdateTime + timePerFrame {
                lastTextureUpdateTime = renderTime
                textureIndex = (textureIndex + 1) % frames.count
            }
            sprite.texture = frames[textureIndex]
        } else {
            let texture = WorkerTexture(angle: CGFloat(agent.rotation))
            sprite.texture = texture.textures.first
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
}
