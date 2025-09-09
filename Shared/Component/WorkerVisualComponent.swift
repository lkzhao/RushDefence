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

class WorkerVisualComponent: Component {
    let sprite = SKSpriteNode()
    var textureIndex: Int = 0
    var lastTextureUpdateTime: Double = 0
    var renderTime: Double = 0
    let timePerFrame: Double = 0.12

    override init() {
        super.init()
        sprite.texture = WorkerTexture.walk1.textures.first
        sprite.size = sprite.texture!.size()
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let agent = entity?.component(ofType: MoveComponent.self) else { return }
        let angle = agent.direction.angle
        let texture = WorkerTexture(angle: CGFloat(angle))
        if agent.isMoving {
            sprite.xScale = agent.direction.x < 0 ? 1 : -1
            let frames = texture.textures
            if renderTime > lastTextureUpdateTime + timePerFrame {
                lastTextureUpdateTime = renderTime
                textureIndex = (textureIndex + 1) % frames.count
            }
            sprite.texture = frames[textureIndex]
        } else {
            sprite.texture = texture.textures.first
            textureIndex = 0
        }
        renderTime += seconds
    }

    override func didAddToEntity() {
        super.didAddToEntity()
        entity?.node.addChild(sprite)
    }
}
