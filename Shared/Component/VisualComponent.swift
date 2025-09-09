//
//  VisualComponent.swift
//  RushDefense iOS
//
//  Protocol for components that own a visual node and can despawn.
//

protocol VisualComponent: GKComponent {
    var sprite: SKSpriteNode { get }
    func despawn()
    func spawn()
}

extension VisualComponent {
    func spawn() {}
    func despawn() {
        (entity as? NodeEntity)?.removeFromScene()
    }
}

extension GKEntity {
    var visualComponent: VisualComponent? {
        components.compactMap { $0 as? VisualComponent }.first
    }
}
