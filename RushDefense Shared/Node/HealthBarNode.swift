//
//  HealthBarNode.swift
//  RushDefense
//
//  A simple health bar node with a background and a fill that
//  scales horizontally to reflect current health percentage.
//

import SpriteKit

class HealthBarNode: SKNode {
    private let background: SKSpriteNode
    private let fill: SKSpriteNode

    private let barWidth: CGFloat
    private let barHeight: CGFloat

    /// Range: 0.0 ... 1.0
    var progress: CGFloat = 1.0 {
        didSet {
            let clamped = max(0, min(1, progress))
            fill.xScale = clamped
            isHidden = (clamped >= 1.0)
        }
    }

    init(width: CGFloat = 16, height: CGFloat = 2) {
        self.barWidth = width
        self.barHeight = height
        background = SKSpriteNode(color: SKColor(white: 0.0, alpha: 0.6), size: CGSize(width: width, height: height))
        fill = SKSpriteNode(color: .green, size: CGSize(width: width, height: height))
        super.init()

        // Anchor left so scaling keeps the left edge fixed.
        background.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        fill.anchorPoint = CGPoint(x: 0.0, y: 0.5)

        // Align both bars so their left edge is centered at the node's origin.
        background.position = CGPoint(x: -barWidth / 2, y: 0)
        fill.position = CGPoint(x: -barWidth / 2, y: 0)

        // Slightly above default z to ensure it's drawn over sprites within the entity.
        zPosition = 10

        addChild(background)
        addChild(fill)

        // Start hidden when full.
        progress = 1.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

