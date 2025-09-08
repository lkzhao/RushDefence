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
    private var lastUpdateTime: TimeInterval = 0

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
        hero.zPosition = 3
        hero.position = map.position + CGPoint(x: 0, y: -50)

        // Portal: place at random location on the map
        let portal = Portal()
        self.portal = portal
        addChild(portal)
        // Compute random position within tile map bounds
        let mapSize = map.tileMap.mapSize
        let halfW = mapSize.width / 2
        let halfH = mapSize.height / 2
        let randX = CGFloat.random(in: -halfW...halfW) + map.position.x
        let randY = CGFloat.random(in: -halfH...halfH) + map.position.y
        portal.position = CGPoint(x: randX, y: randY)

        // Altar: place at center of the map
        let altar = Altar()
        self.altar = altar
        addChild(altar)
        altar.position = map.position

        let wait = SKAction.wait(forDuration: 2.0)
        let doSpawn = SKAction.run {
            portal.spawn()
            altar.spawn()
        }
        portal.run(.sequence([wait, doSpawn]))
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

// MARK: - Frame Update
extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        var dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        // Clamp dt to avoid large jumps on resume
        if dt.isNaN || dt.isInfinite { dt = 1.0 / 60.0 }
        dt = min(max(dt, 0), 0.1)
        hero.update(deltaTime: dt)

        // Dynamic z-ordering: bring obstacles in front when hero is below them
        for node in children.compactMap({ $0 as? SKNode & Obstacle }) {
            node.zPosition = hero.position.y < node.position.y ? 2 : 4
        }
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
            hero.walkPath([destination])
        } else {
            hero.walkPath(path)
        }
    }

    private func planPath(from start: CGPoint, to end: CGPoint) -> [CGPoint] {
        let obstacleNodes: [SKNode & Obstacle] = children.compactMap { $0 as? (SKNode & Obstacle) }
        let rectsScene: [CGRect] = obstacleNodes.compactMap { node in
            node.obstacleRect + node.position
        }

        let heroRadius = max(1.0, hero.calculateAccumulatedFrame().width / 3.0)
        let obstacles: [GKPolygonObstacle] = rectsScene.map { .init(rect: $0) }
        let graph = GKObstacleGraph(obstacles: obstacles, bufferRadius: Float(heroRadius))

        let startNode = GKGraphNode2D(point: start.float2)
        let endNode = GKGraphNode2D(point: end.float2)

        graph.connectUsingObstacles(node: startNode)
        graph.connectUsingObstacles(node: endNode)

        let nodes = graph.findPath(from: startNode, to: endNode) as! [GKGraphNode2D]
        return nodes.map { $0.point }
    }
}

extension GKPolygonObstacle {
    convenience init(rect: CGRect) {
        let pts: [SIMD2<Float>] = [
            rect.topLeft.float2,
            rect.topRight.float2,
            rect.bottomRight.float2,
            rect.bottomLeft.float2,
        ]
        self.init(points: pts)
    }
}

extension CGPoint {
    var float2: SIMD2<Float> {
        SIMD2<Float>(Float(x), Float(y))
    }
}

extension GKGraphNode2D {
    var point: CGPoint {
        CGPoint(x: CGFloat(position.x), y: CGFloat(position.y))
    }
}
