//
//  IconButtonRow.swift
//  RushDefense Shared
//
//  Icon button row UI component for bottom center of game scene.
//

import SpriteKit

class IconButtonRow: SKNode {
    
    override init() {
        super.init()
        setupButtons()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButtons() {
        let buttonSize: CGFloat = 40
        let spacing: CGFloat = 10
        let totalButtons = 9
        let totalWidth = CGFloat(totalButtons) * buttonSize + CGFloat(totalButtons - 1) * spacing
        let startX = -totalWidth / 2
        
        for i in 1...totalButtons {
            let button = SKSpriteNode(imageNamed: "Icon_0\(i)")
            button.size = CGSize(width: buttonSize, height: buttonSize)
            button.position = CGPoint(
                x: startX + CGFloat(i - 1) * (buttonSize + spacing) + buttonSize / 2,
                y: 0
            )
            button.name = "iconButton_\(i)"
            addChild(button)
        }
    }
}