//
//  GameScene.swift
//  RushDefense Shared
//
//  Simplified to only contain the MainCharacter and tap-to-move.
//

import SpriteKit

class GameScene: SKScene {
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
        addChild(hero)
        hero.position = CGPoint(x: size.width / 2, y: size.height / 2)
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
