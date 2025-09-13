import SpriteKit
//
//  VisualComponent.swift
//  RushDefense iOS
//
//  Base class for components that own a visual sprite and can (de)spawn.
//

class VisualComponent: Component {
    let sprite = SKSpriteNode()

    func spawn() {}
    func despawn() { entity?.removeFromMap() }
}

extension Entity {
    var visualComponent: VisualComponent? { components.compactMap { $0 as? VisualComponent }.first }
}
