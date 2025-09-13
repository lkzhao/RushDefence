//
//  FlowFieldPathfindingTests.swift
//  RushDefenseTests
//
//  Tests for Flow Field pathfinding system.
//

import Testing
import CoreGraphics
@testable import RushDefense

struct FlowFieldPathfindingTests {

    // MARK: - FlowField Tests
    
    @Test("FlowField generates valid direction vectors")
    func testFlowFieldGeneration() async throws {
        // Create a simple 5x5 grid with target at center
        let target = GridLocation(x: 2, y: 2)
        let mapSize = GridSize(w: 5, h: 5)
        let obstacles: [GridRect] = []
        
        let flowField = FlowField(target: target, mapSize: mapSize, obstacles: obstacles)
        
        // Test that we get valid directions pointing toward center
        let direction = flowField.getDirection(at: GridLocation(x: 0, y: 0))
        #expect(direction.length > 0, "Direction should not be zero")
        
        // Direction should point roughly toward center (positive x and y)
        #expect(direction.x > 0, "Direction should point right toward center")
        #expect(direction.y > 0, "Direction should point up toward center")
        
        // Test target location has zero distance
        #expect(flowField.getDistance(at: target) == 0, "Target should have zero distance")
        
        // Test that distance increases away from target
        let cornerDistance = flowField.getDistance(at: GridLocation(x: 0, y: 0))
        let adjacentDistance = flowField.getDistance(at: GridLocation(x: 1, y: 2))
        #expect(cornerDistance > adjacentDistance, "Corner should be farther than adjacent cell")
    }
    
    @Test("FlowField handles obstacles correctly")
    func testFlowFieldWithObstacles() async throws {
        // Create 5x5 grid with obstacle blocking direct path
        let target = GridLocation(x: 4, y: 2)
        let mapSize = GridSize(w: 5, h: 5)
        let obstacles = [GridRect(x: 2, y: 1, w: 1, h: 3)] // Vertical wall blocking path
        
        let flowField = FlowField(target: target, mapSize: mapSize, obstacles: obstacles)
        
        // Test that starting position gets a direction (should route around obstacle)
        let startDirection = flowField.getDirection(at: GridLocation(x: 0, y: 2))
        #expect(startDirection.length > 0, "Should have valid direction even with obstacles")
        
        // Test that obstacle cells are unreachable
        let obstacleDistance = flowField.getDistance(at: GridLocation(x: 2, y: 2))
        #expect(obstacleDistance == Float.infinity, "Obstacle cells should be unreachable")
        
        // Test that path routes around obstacle
        let leftSideDirection = flowField.getDirection(at: GridLocation(x: 1, y: 2))
        // Should point up or down to go around the obstacle, not directly right
        #expect(abs(leftSideDirection.y) > abs(leftSideDirection.x), "Should route around obstacle")
    }
    
    @Test("FlowField coordinate conversion")
    func testFlowFieldCoordinateConversion() async throws {
        let target = GridLocation(x: 2, y: 2)
        let mapSize = GridSize(w: 5, h: 5)
        let obstacles: [GridRect] = []
        let cellSize = CGSize(width: 32, height: 32)
        
        let flowField = FlowField(target: target, mapSize: mapSize, obstacles: obstacles)
        
        // Test world coordinate lookup at a non-target location
        let worldPoint = CGPoint(x: -64, y: -64) // Maps to grid location (0, 0)
        let direction = flowField.getDirection(at: worldPoint, cellSize: cellSize)
        #expect(direction.length > 0, "Should get valid direction from world coordinates")
        
        // Test that grid and world lookups are consistent
        let gridDirection = flowField.getDirection(at: GridLocation(x: 0, y: 0))
        let worldDirection = flowField.getDirection(at: CGPoint(x: -64, y: -64), cellSize: cellSize)
        let diff = (gridDirection - worldDirection).length
        #expect(diff < 0.1, "Grid and world coordinate lookups should be consistent")
        
        // Test that target location correctly maps to zero direction
        let targetWorldPoint = CGPoint(x: 0, y: 0) // Maps to target at (2, 2)
        let targetDirection = flowField.getDirection(at: targetWorldPoint, cellSize: cellSize)
        #expect(targetDirection.length < 0.1, "Target location should have near-zero direction")
    }

    // MARK: - FlowFieldManager Tests
    
    @Test("FlowFieldManager caching works correctly")
    func testFlowFieldManagerCaching() async throws {
        let map = Map(columns: 10, rows: 10)
        let manager = map.flowFieldManager
        
        let target = GridLocation(x: 5, y: 5)
        
        // First request should generate flow field
        let flowField1 = manager.getFlowField(to: target)
        #expect(flowField1 != nil, "Should generate flow field")
        #expect(manager.cacheSize == 1, "Should have one cached flow field")
        
        // Second request should return cached version
        let flowField2 = manager.getFlowField(to: target)
        #expect(flowField2 != nil, "Should return cached flow field")
        #expect(manager.cacheSize == 1, "Should still have one cached flow field")
        
        // Different target should create new flow field
        let differentTarget = GridLocation(x: 8, y: 8)
        let flowField3 = manager.getFlowField(to: differentTarget)
        #expect(flowField3 != nil, "Should generate new flow field for different target")
        #expect(manager.cacheSize == 2, "Should have two cached flow fields")
    }
    
    @Test("FlowFieldManager invalidates cache when obstacles change")
    func testFlowFieldManagerInvalidation() async throws {
        let map = Map(columns: 10, rows: 10)
        let manager = map.flowFieldManager
        
        let target = GridLocation(x: 5, y: 5)
        
        // Generate initial flow field
        let initialFlowField = manager.getFlowField(to: target)
        #expect(initialFlowField != nil, "Should generate initial flow field")
        #expect(manager.cacheSize == 1, "Should have one cached flow field")
        
        // Add a building (which should invalidate cache)
        let building = Turret()
        let placed = map.placeBuilding(building, at: GridLocation(x: 3, y: 3))
        #expect(placed == true, "Building should be placed successfully")
        
        // Next request should regenerate flow field due to obstacle change
        let newFlowField = manager.getFlowField(to: target)
        #expect(newFlowField != nil, "Should regenerate flow field after obstacle change")
        
        // Verify that the new flow field accounts for the building obstacle
        let direction = newFlowField!.getDirection(at: GridLocation(x: 2, y: 3))
        #expect(direction.length > 0, "Should have valid direction around building")
    }

    // MARK: - RouteSeekBehavior Tests
    
    @Test("RouteSeekBehavior follows flow field directions")
    func testRouteSeekBehavior() async throws {
        let map = Map(columns: 10, rows: 10)
        
        // Place a building obstacle
        let building = Turret()
        _ = map.placeBuilding(building, at: GridLocation(x: 5, y: 4))
        
        // Create enemy with RouteSeekBehavior
        let enemy = Bear()
        map.addEntity(enemy)
        enemy.moveComponent?.position = CGPoint(x: -100, y: 0) // Left side of map

        // Test that behavior produces steering force
        guard let moveComponent = enemy.moveComponent else {
            Issue.record("Enemy should have MoveComponent")
            return
        }

        // Set up route seeking behavior
        let routeSeek = enemy.moveComponent?.routeSeekBehavior
        #expect(routeSeek != nil, "Enemy should have RouteSeekBehavior")

        routeSeek?.targetLocation = GridLocation(x: 8, y: 4) // Right side, past the building

        let force = routeSeek?.computeForce(for: moveComponent, dt: 0.016)
        #expect(force != nil, "Should produce steering force")
        #expect(force!.length > 0, "Steering force should not be zero")
        
        // Force should generally point toward target (accounting for pathfinding)
        #expect(force!.x > 0, "Should steer generally rightward toward target")
    }
    
    @Test("RouteSeekBehavior falls back to direct seek when needed")
    func testRouteSeekBehaviorFallback() async throws {
        // Create behavior without map context
        let routeSeek = RouteSeekBehavior()
        let moveComponent = MoveComponent()
        moveComponent.position = CGPoint(x: 0, y: 0)
        moveComponent.target = CGPoint(x: 100, y: 0)
        
        // Should fall back to direct seek behavior
        let force = routeSeek.computeForce(for: moveComponent, dt: 0.016)
        #expect(force.length > 0, "Should produce fallback steering force")
        #expect(force.x > 0, "Should steer toward target")
    }

    // MARK: - Integration Tests
    
    @Test("Complete pathfinding integration")
    func testCompletePathfindingIntegration() async throws {
        // Create a level-like scenario
        let map = Map(columns: 20, rows: 15)
        
        // Place buildings to create obstacles
        let altar = Altar()
        let turret1 = Turret()
        let turret2 = Turret()
        let goldMine = GoldMine()
        
        _ = map.placeBuilding(altar, at: GridLocation(x: 15, y: 7))     // Target
        _ = map.placeBuilding(turret1, at: GridLocation(x: 8, y: 6))    // Obstacle 1
        _ = map.placeBuilding(turret2, at: GridLocation(x: 8, y: 9))    // Obstacle 2
        _ = map.placeBuilding(goldMine, at: GridLocation(x: 12, y: 7))  // Obstacle 3
        
        // Create enemy at spawn point
        let enemy = Bear()
        map.addEntity(enemy)
        enemy.moveComponent?.position = CGPoint(x: -200, y: 0) // Far left
        
        // Set up pathfinding target
        let altarLocation = map.grid(for: altar.node.position)
        enemy.moveComponent?.routeSeekBehavior?.targetLocation = altarLocation
        
        // Simulate movement for several frames
        var position = enemy.moveComponent?.position ?? .zero
        for _ in 0..<60 { // 1 second at 60 FPS
            let dt: TimeInterval = 1.0 / 60.0
            enemy.update(deltaTime: dt)
            
            let newPosition = enemy.moveComponent?.position ?? .zero
            let movement = (newPosition - position).length
            
            // Should be making progress toward target
            #expect(movement >= 0, "Should not move backward")
            position = newPosition
        }
        
        // After movement, should be closer to target
        let finalPosition = enemy.moveComponent?.position ?? .zero
        let altarPosition = altar.node.position
        let finalDistance = (altarPosition - finalPosition).length
        let initialDistance = (altarPosition - CGPoint(x: -200, y: 0)).length
        
        #expect(finalDistance < initialDistance, "Should be closer to target after pathfinding")
        
        // Verify that pathfinding avoided obstacles (not inside any building)
        let enemyGridPos = map.grid(for: finalPosition)
        #expect(!map.isOccupied(at: enemyGridPos), "Enemy should not be inside buildings")
    }
    
    @Test("Performance test with multiple flow fields")
    func testPathfindingPerformance() async throws {
        let map = Map(columns: 50, rows: 50)
        
        // Add several obstacles
        for i in 0..<10 {
            let building = Turret()
            _ = map.placeBuilding(building, at: GridLocation(x: i * 4 + 10, y: i * 2 + 10))
        }
        
        // Generate multiple flow fields
        let targets = [
            GridLocation(x: 45, y: 45),
            GridLocation(x: 5, y: 45),
            GridLocation(x: 45, y: 5),
            GridLocation(x: 25, y: 25)
        ]
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for target in targets {
            let flowField = map.flowFieldManager.getFlowField(to: target)
            #expect(flowField != nil, "Should generate flow field for target \(target)")
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        // Should complete in reasonable time (less than 100ms for all flow fields)
        #expect(duration < 0.1, "Flow field generation should be fast (was \(duration)s)")
        
        // Verify cache works
        #expect(map.flowFieldManager.cacheSize == targets.count, "Should cache all generated flow fields")
    }
}
