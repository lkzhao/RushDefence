//
//  GameScene.swift
//  RushDefense Shared
//
//  Simplified to only contain the MainCharacter and tap-to-move.
//

import SpriteKit

class GameScene: EntityScene {
    var map: Map!
    let portal = Portal()
    let altar = Altar()
    let worker = Worker()

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

        map = Map(sizeInPoints: size)
        map.position = CGPoint(x: size.width / 2, y: size.height / 2)
        map.zPosition = -1
        addChild(map)

        addEntity(altar)
        altar.moveComponent?.position = CGPoint(x: size.width * 0.75, y: size.height / 2 - 10)

        addEntity(worker)
        worker.moveComponent?.position = CGPoint(x: size.width * 0.75, y: size.height / 2 - 50)

        addEntity(portal)
        portal.moveComponent?.position = CGPoint(x: size.width * 0.25, y: size.height / 2 + 40)

        let wait = SKAction.wait(forDuration: 2.0)
        let doSpawn = SKAction.run {
            self.portal.visualComponent?.spawn()
            self.altar.visualComponent?.spawn()
        }
        portal.node.run(.sequence([wait, doSpawn]))
    }
}

#if os(iOS) || os(tvOS)
extension GameScene {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
//        routeHero(to: location)
        worker.moveComponent?.target = location
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
//        routeHero(to: location)
        worker.moveComponent?.target = location
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
//extension GameScene {
//    private func routeHero(to destination: CGPoint) {
//        let path = planPath(from: hero.position, to: destination)
//        if path.isEmpty {
//            hero.walkPath([destination])
//        } else {
//            hero.walkPath(path)
//        }
//    }
//
//    private func planPath(from start: CGPoint, to end: CGPoint) -> [CGPoint] {
//        let obstacleNodes: [SKNode & Obstacle] = children.compactMap { $0 as? (SKNode & Obstacle) }
//        let rectsScene: [CGRect] = obstacleNodes.compactMap { node in
//            node.obstacleRect + node.position
//        }
//
//        let heroRadius = max(1.0, hero.calculateAccumulatedFrame().width / 3.0)
//        let obstacles: [GKPolygonObstacle] = rectsScene.map { .init(rect: $0) }
//        let graph = GKObstacleGraph(obstacles: obstacles, bufferRadius: Float(heroRadius))
//
//        let startNode = GKGraphNode2D(point: start.float2)
//        let endNode = GKGraphNode2D(point: end.float2)
//
//        graph.connectUsingObstacles(node: startNode)
//        graph.connectUsingObstacles(node: endNode)
//
//        let nodes = graph.findPath(from: startNode, to: endNode) as! [GKGraphNode2D]
//        return nodes.map { $0.point }
//    }
//}
//
//extension GKPolygonObstacle {
//    convenience init(rect: CGRect) {
//        let pts: [SIMD2<Float>] = [
//            rect.topLeft.float2,
//            rect.topRight.float2,
//            rect.bottomRight.float2,
//            rect.bottomLeft.float2,
//        ]
//        self.init(points: pts)
//    }
//}
