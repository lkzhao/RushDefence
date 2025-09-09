//
//  IdleSpawnVisualComponent.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

class IdleSpawnVisualComponent: GKComponent, VisualComponent {
    let sprite = SKSpriteNode()
    var timePerFrame: TimeInterval = 0.12

    let idleTexture: String
    let spawnTexture: String

    init(idleTexture: String, spawnTexture: String) {
        self.idleTexture = idleTexture
        self.spawnTexture = spawnTexture
        super.init()
        let initialTexture = TextureCache.shared.textures(for: spawnTexture).first
        sprite.texture = initialTexture
        sprite.size = initialTexture?.size() ?? .zero
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didAddToEntity() {
        super.didAddToEntity()
        if let entity = entity as? NodeEntity {
            entity.node.addChild(sprite)
        }
    }

    func spawn() {
        sprite.removeAction(forKey: "spawn")
        sprite.removeAction(forKey: "idle")

        let startFrames = TextureCache.shared.textures(for: spawnTexture)

        sprite.texture = startFrames.first
        let start = SKAction.animate(with: startFrames, timePerFrame: timePerFrame, resize: false, restore: false)
        let beginIdle = SKAction.run { [weak self] in
            guard let self = self else { return }
            let idleFrames = TextureCache.shared.textures(for: idleTexture)
            self.sprite.texture = idleFrames.first
            let idle = SKAction.repeatForever(
                SKAction.animate(with: idleFrames, timePerFrame: self.timePerFrame, resize: false, restore: false)
            )
            self.sprite.run(idle, withKey: "idle")
        }
        let sequence = SKAction.sequence([start, beginIdle])
        sprite.run(sequence, withKey: "spawn")
    }

    func despawn() {
        // Stop any ongoing animations before reversing the spawn.
        sprite.removeAllActions()

        let startFrames = TextureCache.shared.textures(for: spawnTexture)
        let reversedFrames = Array(startFrames.reversed())

        // Ensure we start from the fully spawned frame.
        if let first = reversedFrames.first {
            sprite.texture = first
        }

        let reverseSpawn = SKAction.animate(with: reversedFrames, timePerFrame: timePerFrame, resize: false, restore: false)
        let remove = SKAction.run { [weak self] in
            (self?.entity as? NodeEntity)?.removeFromScene()
        }
        let sequence = SKAction.sequence([reverseSpawn, remove])
        sprite.run(sequence, withKey: "despawn")
    }
}
