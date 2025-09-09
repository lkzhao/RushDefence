//
//  Component.swift
//  RushDefense
//
//  Lightweight component base to replace GameplayKit's GKComponent.
//

import Foundation

class Component {
    weak var entity: Entity?

    init() {}

    func didAddToEntity() {}
    func willRemoveFromEntity() {}
    func update(deltaTime seconds: TimeInterval) {}
}

extension Component: Then {}
