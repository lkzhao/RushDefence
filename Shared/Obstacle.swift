//
//  Obstacle.swift
//  RushDefense
//
//  Defines circular obstacle interface for path planning.
//

import SpriteKit

protocol Obstacle {
    /// Axis-aligned rect for the obstacle in the node's local coordinates,
    /// typically centered on the node (e.g., using `sprite.size`).
    var obstacleRect: CGRect { get }
}
