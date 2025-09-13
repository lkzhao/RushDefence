//
//  GameScene.swift
//  RushDefense Shared
//
//  GameScene hosts a Level1Map and handles pan/zoom.
//

import SpriteKit
import UIKit

class GameScene: SKScene {
    var map: Level1Map!
    private var lastUpdateTime: TimeInterval = 0
    private var pinchStartScale: CGFloat = 1.0
    private var lastPanLocation: CGPoint?
    private var pinchAnchorScene: CGPoint = .zero
    private var pinchAnchorLocal: CGPoint = .zero
    private var goldLabel: SKLabelNode!
    private var iconButtonRow: IconButtonRow!
    private var restartButton: SKShapeNode!

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
        map.delegate = self
        map.node.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(map.node)
        updateZoomLimits()
        let sceneSize = size
        let mapSize = map.pointSize
        let aspectFill = max(sceneSize.width / mapSize.width, sceneSize.height / mapSize.height)
        map.setZoom(aspectFill)
        
        // Setup gold display UI
        setupGoldDisplay()
        
        // Setup restart button UI
        setupRestartButton()
        
        // Setup icon buttons UI
        setupIconButtonRow()
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
        panGR.allowedScrollTypesMask = .continuous // Only handle continuous scrolling (touch), not discrete (mouse wheel)
        panGR.delegate = self
        view.addGestureRecognizer(panGR)
        
        // Add separate pan gesture recognizer specifically for mouse scroll wheel events
        let scrollGR = UIPanGestureRecognizer(target: self, action: #selector(handleScroll(_:)))
        scrollGR.minimumNumberOfTouches = 0
        scrollGR.maximumNumberOfTouches = 0
        scrollGR.allowedScrollTypesMask = .discrete // Only handle discrete scrolling (mouse wheel)
        scrollGR.delegate = self
        view.addGestureRecognizer(scrollGR)
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGR.numberOfTapsRequired = 1
        tapGR.delegate = self
        view.addGestureRecognizer(tapGR)
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
    
    @objc private func handleScroll(_ recognizer: UIPanGestureRecognizer) {
        guard let view = self.view else { return }
        
        // Handle mouse scroll wheel events as zoom
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: view)
            let scrollDelta = -translation.y // Invert Y axis for natural zoom direction
            let zoomSensitivity: CGFloat = 0.005 // Adjust sensitivity as needed
            let zoomFactor = 1.0 + (scrollDelta * zoomSensitivity)
            
            // Get the mouse location for zoom anchor
            let mouseLocation = recognizer.location(in: view)
            let scenePoint = convertPoint(fromView: mouseLocation)
            let localPoint = map.node.convert(scenePoint, from: self)
            
            // Apply zoom
            let newZoom = map.zoom * zoomFactor
            map.setZoom(newZoom)
            
            // Adjust position to keep zoom centered on mouse cursor
            let newScenePoint = map.node.convert(localPoint, to: self)
            let delta = scenePoint - newScenePoint
            map.node.position += delta
            clampMapPosition()
            
            recognizer.setTranslation(.zero, in: view)
        }
    }

    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let view = self.view else { return }
        let tapLocation = recognizer.location(in: view)
        let scenePoint = convertPoint(fromView: tapLocation)
        
        // Check if restart button was tapped
        let touchedNode = atPoint(scenePoint)
        if touchedNode.name == "restartButton" || touchedNode.parent?.name == "restartButton" {
            restartGame()
            return
        }
        
        // Otherwise handle turret placement
        let mapPoint = map.node.convert(scenePoint, from: self)
        attemptTurretPlacement(at: mapPoint)
    }
}

// MARK: - Gesture Recognizer Delegate
extension GameScene: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow pan and pinch to work together, but not tap with pan/pinch
        if gestureRecognizer is UITapGestureRecognizer || otherGestureRecognizer is UITapGestureRecognizer {
            return false
        }
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
        let mapSize = map.pointSize
        let aspectFit = min(sceneSize.width / mapSize.width, sceneSize.height / mapSize.height)
        let aspectFill = max(sceneSize.width / mapSize.width, sceneSize.height / mapSize.height)

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

// MARK: - Gold Display
private extension GameScene {
    func setupGoldDisplay() {
        goldLabel = SKLabelNode(fontNamed: "Arial-Bold")
        goldLabel.fontSize = 24
        goldLabel.fontColor = .yellow
        goldLabel.text = "Gold: 0"
        goldLabel.horizontalAlignmentMode = .right
        goldLabel.verticalAlignmentMode = .top
        goldLabel.position = CGPoint(x: size.width - 20, y: size.height - 20)
        goldLabel.zPosition = 1000
        addChild(goldLabel)
    }
    
    func updateGoldDisplay() {
        goldLabel.text = "Gold: \(map.resourceManager.currentGold)"
    }
}

// MARK: - Icon Buttons
private extension GameScene {
    func setupIconButtonRow() {
        iconButtonRow = IconButtonRow()
        iconButtonRow.position = CGPoint(x: size.width / 2, y: 60)
        iconButtonRow.zPosition = 1000
        addChild(iconButtonRow)
    }
}

// MARK: - Restart Button
private extension GameScene {
    func setupRestartButton() {
        restartButton = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 60, height: 30), cornerRadius: 6)
        restartButton.fillColor = .systemBlue
        restartButton.strokeColor = .white
        restartButton.lineWidth = 1
        restartButton.position = CGPoint(x: 20, y: size.height - 50)
        restartButton.name = "restartButton"
        restartButton.zPosition = 1000
        
        let restartLabel = SKLabelNode(fontNamed: "Arial-Bold")
        restartLabel.text = "RESTART"
        restartLabel.fontSize = 12
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: 30, y: 10)
        restartLabel.horizontalAlignmentMode = .center
        restartLabel.verticalAlignmentMode = .center
        restartButton.addChild(restartLabel)
        
        addChild(restartButton)
    }
}

// MARK: - Update
extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        map.update(deltaTime: dt)
        updateGoldDisplay()
        lastUpdateTime = currentTime
    }
}

// MARK: - Size Changes
extension GameScene {
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        updateZoomLimits()
        goldLabel?.position = CGPoint(x: size.width - 20, y: size.height - 20)
        iconButtonRow?.position = CGPoint(x: size.width / 2, y: 60)
        restartButton?.position = CGPoint(x: 20, y: size.height - 50)
    }
}

// MARK: - Turret Placement
private extension GameScene {
    func attemptTurretPlacement(at point: CGPoint) {
        let gridLocation = map.grid(for: point)
        let turretCost = Turret.cost
        let turretSize = GridSize(w: 2, h: 2)
        let placementRect = GridRect(origin: gridLocation, size: turretSize)
        
        // Check if placement is valid
        guard map.resourceManager.currentGold >= turretCost,
              map.gridBounds.contains(placementRect),
              map.isFree(placementRect) else {
            print("Cannot place turret: insufficient gold, out of bounds, or location occupied")
            return
        }
        
        // Create and place turret
        let turret = Turret()
        guard map.placeBuilding(turret, at: gridLocation) else {
            print("Failed to place turret")
            return
        }
        
        // Deduct cost and spawn visual
        map.resourceManager.spendGold(turretCost)
        turret.visualComponent?.spawn()
        print("Turret placed at \(gridLocation) for \(turretCost) gold")
    }
}

// MARK: - Game Over
extension GameScene {
    func showGameOver() {
        let gameOverScene = GameOverScene(size: size)
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(gameOverScene, transition: transition)
    }
    
    func restartGame() {
        let newGameScene = GameScene(size: size)
        let transition = SKTransition.fade(withDuration: 0.3)
        view?.presentScene(newGameScene, transition: transition)
    }
}

// MARK: - Map Delegate
extension GameScene: MapDelegate {
    func gameOver() {
        showGameOver()
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
