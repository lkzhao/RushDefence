//
//  Component.swift
//  RushDefense
//
//  Lightweight component base to replace GameplayKit's GKComponent.
//

import Foundation

class Component {
    weak var entity: Entity?
    private(set) var lastUpdateTime: TimeInterval = 0

    init() {}

    func didAddToEntity() {}
    func willRemoveFromEntity() {}
    func update(deltaTime seconds: TimeInterval) {
        lastUpdateTime += seconds
    }
}

extension Component: Then {}
