//
//  GameScene.swift
//  RushDefense Shared
//
//  GameScene hosts a Level1Map and handles pan/zoom.
//

import SpriteKit
#if os(iOS)
import UIKit
#endif

class GameScene: SKScene {
    var map: Level1Map!
    private var lastUpdateTime: TimeInterval = 0
    private var pinchStartScale: CGFloat = 1.0
    private var lastPanLocation: CGPoint?
    private var pinchAnchorScene: CGPoint = .zero
    private var pinchAnchorLocal: CGPoint = .zero

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

        // Create Level1Map and add its node (Level1Map places buildings and spawners)
        map = Level1Map()
        map.node.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(map.node)
    }
}

#if os(iOS) || os(tvOS)
extension GameScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        #if os(iOS)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        view.addGestureRecognizer(pinch)
        #endif
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPanLocation = nil
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Only handle single-finger panning to avoid conflict with pinch
        if let count = event?.allTouches?.count, count > 1 { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if let last = lastPanLocation {
            let delta = location - last
            map.node.position += delta
            clampMapPosition()
        }
        lastPanLocation = location
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let count = event?.allTouches?.count, count > 1 { return }
        guard let touch = touches.first else { return }
        lastPanLocation = touch.location(in: self)
    }

    #if os(iOS)
    @objc private func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .began:
            pinchStartScale = map.zoom
            if let view = self.view {
                let pView = recognizer.location(in: view)
                let pScene = convertPoint(fromView: pView)
                pinchAnchorScene = pScene
                pinchAnchorLocal = map.node.convert(pScene, from: self)
            }
        case .changed, .ended, .cancelled:
            let newScale = pinchStartScale * recognizer.scale
            map.setZoom(newScale)
            // Adjust position so the pinch anchor remains visually stable
            let mapped = map.node.convert(pinchAnchorLocal, to: self)
            let delta = pinchAnchorScene - mapped
            map.node.position += delta
            clampMapPosition()
        default:
            break
        }
    }
    #endif
}
#endif

#if os(OSX)
extension GameScene {
    override func mouseDown(with event: NSEvent) { lastPanLocation = event.location(in: self) }
    override func mouseDragged(with event: NSEvent) {
        let location = event.location(in: self)
        if let last = lastPanLocation {
            let delta = location - last
            map.node.position += delta
            clampMapPosition()
        }
        lastPanLocation = location
    }
    override func mouseUp(with event: NSEvent) { lastPanLocation = nil }
}
#endif

// MARK: - Map Bounds
private extension GameScene {
    func clampMapPosition() {
        guard map != nil else { return }
        let sceneSize = size
        let center = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        let scale = map.zoom
        let contentW = CGFloat(map.columns) * map.cellSize.width * scale
        let contentH = CGFloat(map.rows) * map.cellSize.height * scale

        // If content smaller than viewport, lock to center.
        let offsetX = max(0, (contentW - sceneSize.width) / 2)
        let offsetY = max(0, (contentH - sceneSize.height) / 2)

        let minX = center.x - offsetX
        let maxX = center.x + offsetX
        let minY = center.y - offsetY
        let maxY = center.y + offsetY

        var pos = map.node.position
        pos.x = min(max(pos.x, minX), maxX)
        pos.y = min(max(pos.y, minY), maxY)
        map.node.position = pos
    }
}

// MARK: - Update
extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        map.update(deltaTime: dt)
        lastUpdateTime = currentTime
    }
}

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
