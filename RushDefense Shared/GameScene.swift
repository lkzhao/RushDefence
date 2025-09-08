//
//  GameScene.swift
//  RushDefense Shared
//
//  Simplified to only contain the MainCharacter and tap-to-move.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private var map: Map!
    private let hero = MainCharacter()
    private var portal: Portal!
    private var altar: Altar!

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
        // Map behind hero
        map = Map(sizeInPoints: size)
        map.position = CGPoint(x: size.width / 2, y: size.height / 2)
        map.zPosition = -1
        addChild(map)

        // Hero
        addChild(hero)
        hero.zPosition = 1
        hero.position = CGPoint(x: size.width / 2, y: size.height / 2)

        // Portal: place at random location on the map, spawn after delay
        let portal = Portal()
        self.portal = portal
        portal.zPosition = 0
        addChild(portal)
        // Compute random position within tile map bounds
        let mapSize = map.tileMap.mapSize
        let halfW = mapSize.width / 2
        let halfH = mapSize.height / 2
        let randX = CGFloat.random(in: -halfW...halfW) + map.position.x
        let randY = CGFloat.random(in: -halfH...halfH) + map.position.y
        portal.position = CGPoint(x: randX, y: randY)

        let wait = SKAction.wait(forDuration: 2.0)
        let doSpawn = SKAction.run { [weak portal] in portal?.spawn() }
        portal.run(.sequence([wait, doSpawn]))

        // Altar: place at center of the map and spawn immediately
        let altar = Altar()
        self.altar = altar
        altar.zPosition = 0
        addChild(altar)
        altar.position = map.position
        altar.spawn()
    }
}

#if os(iOS) || os(tvOS)
extension GameScene {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        routeHero(to: location)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        routeHero(to: location)
    }
}
#endif

#if os(OSX)
extension GameScene {
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        routeHero(to: location)
    }
}
#endif

// MARK: - Pathfinding
extension GameScene {
    private func routeHero(to destination: CGPoint) {
        let path = planPath(from: hero.position, to: destination)
        if path.isEmpty {
            hero.walkTo(destination)
        } else {
            hero.walkPath(path)
        }
    }

    private func planPath(from start: CGPoint, to end: CGPoint) -> [CGPoint] {
        // Build obstacles directly from SpriteKit physics bodies
        let obstacleNodes: [SKNode] = [portal as SKNode?, altar as SKNode?].compactMap { $0 }
        let obstacles: [GKPolygonObstacle] = SKNode.obstacles(fromNodePhysicsBodies: obstacleNodes)

        // Buffer based on the hero's physics radius (width / 3)
        let heroWidth = hero.calculateAccumulatedFrame().width
        let heroRadius = Float(max(1.0, heroWidth / 3.0))

        let graph = GKObstacleGraph(obstacles: obstacles, bufferRadius: heroRadius)

        let startNode = GKGraphNode2D(point: vector_float2(Float(start.x), Float(start.y)))
        let endNode = GKGraphNode2D(point: vector_float2(Float(end.x), Float(end.y)))

        graph.connectUsingObstacles(node: startNode)
        graph.connectUsingObstacles(node: endNode)

        let nodes = graph.findPath(from: startNode, to: endNode) as? [GKGraphNode2D] ?? []

        // Cleanup temporary nodes
        graph.remove([startNode, endNode])

        // Convert path nodes to CGPoints, dropping the first if it's too close to start
        var points: [CGPoint] = nodes.map { CGPoint(x: CGFloat($0.position.x), y: CGFloat($0.position.y)) }
        if let first = points.first, hypot(first.x - start.x, first.y - start.y) < 1 {
            points.removeFirst()
        }
        return points
    }
}
