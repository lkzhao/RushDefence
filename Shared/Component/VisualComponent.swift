import SpriteKit
//
//  VisualComponent.swift
//  RushDefense iOS
//
//  Protocol for components that own a visual node and can despawn.
//
protocol VisualComponent: AnyObject {
    var sprite: SKSpriteNode { get }
    func despawn()
    func spawn()
}

extension VisualComponent where Self: Component {
    func spawn() {}
    func despawn() {
        entity?.removeFromScene()
    }
}

extension Entity {
    var visualComponent: VisualComponent? { components.compactMap { $0 as? VisualComponent }.first }
}
