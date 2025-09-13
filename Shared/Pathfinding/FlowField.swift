//
//  FlowField.swift
//  RushDefense
//
//  Flow field pathfinding for efficient many-to-one navigation.
//

import CoreGraphics
import Foundation

struct FlowField {
    let targetLocation: GridLocation
    let mapSize: GridSize
    private let directions: [[CGPoint]]
    private let distances: [[Float]]
    
    init(target: GridLocation, mapSize: GridSize, obstacles: [GridRect]) {
        self.targetLocation = target
        self.mapSize = mapSize
        
        // Initialize distance field with high values
        var distanceGrid = Array(repeating: Array(repeating: Float.infinity, count: mapSize.w), count: mapSize.h)
        var obstacleGrid = Array(repeating: Array(repeating: false, count: mapSize.w), count: mapSize.h)
        
        // Mark obstacles
        for rect in obstacles {
            for y in rect.minY..<rect.maxYExclusive {
                for x in rect.minX..<rect.maxXExclusive {
                    if y >= 0 && y < mapSize.h && x >= 0 && x < mapSize.w {
                        obstacleGrid[y][x] = true
                    }
                }
            }
        }
        
        // Generate distance field using Dijkstra's algorithm
        distanceGrid = Self.generateDistanceField(target: target, mapSize: mapSize, obstacles: obstacleGrid)
        
        // Generate direction field from distance gradients
        let directionGrid = Self.generateDirectionField(distanceField: distanceGrid, mapSize: mapSize)
        
        self.distances = distanceGrid
        self.directions = directionGrid
    }
    
    func getDirection(at location: GridLocation) -> CGPoint {
        guard location.x >= 0 && location.x < mapSize.w &&
              location.y >= 0 && location.y < mapSize.h else {
            return .zero
        }
        return directions[location.y][location.x]
    }
    
    func getDirection(at point: CGPoint, cellSize: CGSize) -> CGPoint {
        // Convert world point to grid location
        let totalW = CGFloat(mapSize.w) * cellSize.width
        let totalH = CGFloat(mapSize.h) * cellSize.height
        let gx = Int(floor((point.x + totalW / 2) / cellSize.width))
        let gy = Int(floor((point.y + totalH / 2) / cellSize.height))
        
        let gridLoc = GridLocation(x: gx, y: gy)
        return getDirection(at: gridLoc)
    }
    
    func getDistance(at location: GridLocation) -> Float {
        guard location.x >= 0 && location.x < mapSize.w &&
              location.y >= 0 && location.y < mapSize.h else {
            return Float.infinity
        }
        return distances[location.y][location.x]
    }
    
    // MARK: - Distance Field Generation
    
    private static func generateDistanceField(target: GridLocation, mapSize: GridSize, obstacles: [[Bool]]) -> [[Float]] {
        var distances = Array(repeating: Array(repeating: Float.infinity, count: mapSize.w), count: mapSize.h)
        var queue: [(GridLocation, Float)] = []
        
        // Start from target with distance 0
        if target.x >= 0 && target.x < mapSize.w && target.y >= 0 && target.y < mapSize.h {
            distances[target.y][target.x] = 0
            queue.append((target, 0))
        }
        
        // 8-directional movement costs
        let neighbors = [
            (-1, -1, sqrt(2.0)), (-1, 0, 1.0), (-1, 1, sqrt(2.0)),
            (0, -1, 1.0),                       (0, 1, 1.0),
            (1, -1, sqrt(2.0)),  (1, 0, 1.0),  (1, 1, sqrt(2.0))
        ]
        
        var queueIndex = 0
        while queueIndex < queue.count {
            let (current, currentDist) = queue[queueIndex]
            queueIndex += 1
            
            // Skip if we've found a better path already
            if currentDist > distances[current.y][current.x] {
                continue
            }
            
            // Check all neighbors
            for (dx, dy, cost) in neighbors {
                let nx = current.x + dx
                let ny = current.y + dy
                
                // Bounds check
                guard nx >= 0 && nx < mapSize.w && ny >= 0 && ny < mapSize.h else { continue }
                
                // Skip obstacles
                guard !obstacles[ny][nx] else { continue }
                
                let newDist = currentDist + Float(cost)
                if newDist < distances[ny][nx] {
                    distances[ny][nx] = newDist
                    queue.append((GridLocation(x: nx, y: ny), newDist))
                }
            }
        }
        
        return distances
    }
    
    // MARK: - Direction Field Generation
    
    private static func generateDirectionField(distanceField: [[Float]], mapSize: GridSize) -> [[CGPoint]] {
        var directions = Array(repeating: Array(repeating: CGPoint.zero, count: mapSize.w), count: mapSize.h)
        
        for y in 0..<mapSize.h {
            for x in 0..<mapSize.w {
                let currentDist = distanceField[y][x]
                
                // Skip unreachable cells
                guard currentDist != Float.infinity else { continue }
                
                var bestDirection = CGPoint.zero
                var bestDistance = currentDist
                
                // Check 8 neighbors to find steepest descent
                let neighbors = [
                    (-1, -1), (-1, 0), (-1, 1),
                    (0, -1),           (0, 1),
                    (1, -1),  (1, 0),  (1, 1)
                ]
                
                for (dx, dy) in neighbors {
                    let nx = x + dx
                    let ny = y + dy
                    
                    // Bounds check
                    guard nx >= 0 && nx < mapSize.w && ny >= 0 && ny < mapSize.h else { continue }
                    
                    let neighborDist = distanceField[ny][nx]
                    if neighborDist < bestDistance {
                        bestDistance = neighborDist
                        bestDirection = CGPoint(x: CGFloat(dx), y: CGFloat(dy)).normalized()
                    }
                }
                
                directions[y][x] = bestDirection
            }
        }
        
        return directions
    }
}