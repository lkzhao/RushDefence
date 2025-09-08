//
//  GameScene.swift
//  RushDefense Shared
//
//  Simplified to only contain the MainCharacter and tap-to-move.
//

import SpriteKit

class GameScene: SKScene {
    private var map: Map!
    private let hero = MainCharacter()

    override init(size: CGSize) {
        super.init(size: size)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        scaleMode = .aspectFill
        // Map behind hero
        map = Map(sizeInPoints: size)
        map.position = CGPoint(x: size.width / 2, y: size.height / 2)
        map.zPosition = -1
        addChild(map)

        // Hero
        addChild(hero)
        hero.zPosition = 1
        hero.position = CGPoint(x: size.width / 2, y: size.height / 2)

        // Portal: place at random location on the map, spawn after delay
        let portal = Portal()
        portal.zPosition = 0
        addChild(portal)
        // Compute random position within tile map bounds
        let mapSize = map.tileMap.mapSize
        let halfW = mapSize.width / 2
        let halfH = mapSize.height / 2
        let randX = CGFloat.random(in: -halfW...halfW) + map.position.x
        let randY = CGFloat.random(in: -halfH...halfH) + map.position.y
        portal.position = CGPoint(x: randX, y: randY)

        let wait = SKAction.wait(forDuration: 2.0)
        let doSpawn = SKAction.run { [weak portal] in portal?.spawn() }
        portal.run(.sequence([wait, doSpawn]))

        // Altar: place at center of the map and spawn immediately
        let altar = Altar()
        altar.zPosition = 0
        addChild(altar)
        altar.position = map.position
        altar.spawn()
    }
}

#if os(iOS) || os(tvOS)
extension GameScene {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        hero.walkTo(location)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        hero.walkTo(location)
    }
}
#endif

#if os(OSX)
extension GameScene {
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        hero.walkTo(location)
    }
}
#endif
