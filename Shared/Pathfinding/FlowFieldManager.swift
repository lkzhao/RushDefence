//
//  FlowFieldManager.swift
//  RushDefense
//
//  Manages flow field generation and caching for efficient pathfinding.
//

import Foundation

class FlowFieldManager {
    weak var map: Map?
    private var flowFields: [GridLocation: FlowField] = [:]
    private var obstacleVersion: Int = 0
    private var cachedObstacles: [GridRect] = []
    
    init(map: Map) {
        self.map = map
    }
    
    func getFlowField(to target: GridLocation) -> FlowField? {
        guard let map = map else { return nil }
        
        // Check if we need to update cached obstacles
        let currentObstacles = map.getObstacles()
        if currentObstacles != cachedObstacles {
            invalidateFlowFields()
            cachedObstacles = currentObstacles
        }
        
        // Return cached flow field if available
        if let cached = flowFields[target] {
            return cached
        }
        
        // Generate new flow field
        let mapSize = GridSize(w: map.columns, h: map.rows)
        let flowField = FlowField(target: target, mapSize: mapSize, obstacles: currentObstacles)
        flowFields[target] = flowField
        
        return flowField
    }
    
    func invalidateFlowFields() {
        obstacleVersion += 1
        flowFields.removeAll()
    }
    
    func invalidateFlowField(for target: GridLocation) {
        flowFields.removeValue(forKey: target)
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        flowFields.removeAll()
        cachedObstacles.removeAll()
    }
    
    var cacheSize: Int {
        return flowFields.count
    }
    
    var cachedTargets: [GridLocation] {
        return Array(flowFields.keys)
    }
}

// MARK: - GridRect Equality for Obstacle Comparison

extension Array where Element == GridRect {
    static func ==(lhs: [GridRect], rhs: [GridRect]) -> Bool {
        guard lhs.count == rhs.count else { return false }
        
        // Sort both arrays for comparison (since order shouldn't matter)
        let sortedLhs = lhs.sorted { rect1, rect2 in
            if rect1.origin.x != rect2.origin.x { return rect1.origin.x < rect2.origin.x }
            if rect1.origin.y != rect2.origin.y { return rect1.origin.y < rect2.origin.y }
            if rect1.size.w != rect2.size.w { return rect1.size.w < rect2.size.w }
            return rect1.size.h < rect2.size.h
        }
        
        let sortedRhs = rhs.sorted { rect1, rect2 in
            if rect1.origin.x != rect2.origin.x { return rect1.origin.x < rect2.origin.x }
            if rect1.origin.y != rect2.origin.y { return rect1.origin.y < rect2.origin.y }
            if rect1.size.w != rect2.size.w { return rect1.size.w < rect2.size.w }
            return rect1.size.h < rect2.size.h
        }
        
        return sortedLhs.elementsEqual(sortedRhs)
    }
}