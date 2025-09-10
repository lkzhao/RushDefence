//
//  GameScene.swift
//  RushDefense Shared
//
//  GameScene hosts a Level1Map and handles pan/zoom.
//

import SpriteKit
import UIKit
import BaseToolbox

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
        scaleMode = .resizeFill

        // Create Level1Map and add its node (Level1Map places buildings and spawners)
        map = Level1Map()
        map.node.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(map.node)
    }
}

extension GameScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGR.delegate = self
        view.addGestureRecognizer(pinchGR)
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGR.minimumNumberOfTouches = 1
        panGR.maximumNumberOfTouches = 2
        panGR.allowedScrollTypesMask = .all
        panGR.delegate = self
        view.addGestureRecognizer(panGR)
    }

    @objc private func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .began:
            print("Pinch began")
            pinchStartScale = map.zoom
            if let view = self.view {
                let pView = recognizer.location(in: view)
                let pScene = convertPoint(fromView: pView)
                pinchAnchorScene = pScene
                pinchAnchorLocal = map.node.convert(pScene, from: self)
            }
        case .changed:
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

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let view = self.view else { return }
        switch recognizer.state {
        case .began:
            print("Pan began")
        case .changed:
            let t = recognizer.translation(in: view)
            // Convert translation vector from view space to scene space via two points
            let p0 = convertPoint(fromView: .zero)
            let p1 = convertPoint(fromView: CGPoint(x: t.x, y: t.y))
            let delta = p1 - p0
            map.node.position += delta
            recognizer.setTranslation(.zero, in: view)
            clampMapPosition()
        default:
            break
        }
    }
}

// MARK: - Gesture Recognizer Delegate
extension GameScene: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Map Bounds
private extension GameScene {
    func updateZoomLimits() {
        guard map != nil else { return }
        let sceneSize = size

        // Content size of the map in its unscaled coordinate space
        let contentW = CGFloat(map.columns) * map.cellSize.width
        let contentH = CGFloat(map.rows) * map.cellSize.height
        guard contentW > 0 && contentH > 0 else { return }

        // aspectFit: entire map visible; aspectFill: screen fully filled
        let aspectFit = min(sceneSize.width / contentW, sceneSize.height / contentH)
        let aspectFill = max(sceneSize.width / contentW, sceneSize.height / contentH)

        map.minimumZoom = aspectFit
        map.maximumZoom = 4.0 * aspectFill

        // Clamp current zoom and position to new bounds
        map.setZoom(map.zoom)
        clampMapPosition()
    }

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

// MARK: - Size Changes
extension GameScene {
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        updateZoomLimits()
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
