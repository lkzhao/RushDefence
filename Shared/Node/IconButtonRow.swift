//
//  IconButtonRow.swift
//  RushDefense Shared
//
//  Icon button row UI component for bottom center of game scene.
//

import SpriteKit

class IconButtonRow: SKNode {
    
    private var selectedButtonIndex: Int? = nil
    private var buttons: [SKSpriteNode] = []
    
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
            let button = SKSpriteNode(imageNamed: "Icons/Icon_\(i)")
            button.size = CGSize(width: buttonSize, height: buttonSize)
            button.position = CGPoint(
                x: startX + CGFloat(i - 1) * (buttonSize + spacing) + buttonSize / 2,
                y: 0
            )
            button.name = "iconButton_\(i)"
            buttons.append(button)
            addChild(button)
        }
    }
    
    func selectButton(index: Int) {
        clearSelection()
        
        guard index >= 1 && index <= buttons.count else { return }
        
        selectedButtonIndex = index
        let button = buttons[index - 1]
        
        let border = SKShapeNode(rect: CGRect(
            x: -button.size.width / 2,
            y: -button.size.height / 2,
            width: button.size.width,
            height: button.size.height
        ))
        border.strokeColor = .yellow
        border.lineWidth = 2
        border.fillColor = .clear
        border.name = "selection_border"
        button.addChild(border)
    }
    
    func clearSelection() {
        selectedButtonIndex = nil
        for button in buttons {
            button.childNode(withName: "selection_border")?.removeFromParent()
        }
    }
    
    func getSelectedTurretType() -> String? {
        guard let index = selectedButtonIndex else { return nil }
        return "\(index)"
    }
}