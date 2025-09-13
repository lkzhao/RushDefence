//
//  GameOverScene.swift
//  RushDefense
//
//  Game Over scene with restart functionality.
//

import SpriteKit

class GameOverScene: SKScene {
    private var restartButton: SKShapeNode!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupUI()
    }
    
    private func setupUI() {
        // Semi-transparent background
        backgroundColor = SKColor.black.withAlphaComponent(0.7)
        
        // Game Over label
        let gameOverLabel = SKLabelNode(fontNamed: "Arial-Bold")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 40)
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.verticalAlignmentMode = .center
        addChild(gameOverLabel)
        
        // Restart button
        restartButton = SKShapeNode(rect: CGRect(x: -80, y: -20, width: 160, height: 40), cornerRadius: 8)
        restartButton.fillColor = .systemBlue
        restartButton.strokeColor = .white
        restartButton.lineWidth = 2
        restartButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 40)
        restartButton.name = "restartButton"
        
        let restartLabel = SKLabelNode(fontNamed: "Arial-Bold")
        restartLabel.text = "RESTART"
        restartLabel.fontSize = 20
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: 0, y: -6)
        restartLabel.horizontalAlignmentMode = .center
        restartLabel.verticalAlignmentMode = .center
        restartButton.addChild(restartLabel)
        
        addChild(restartButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "restartButton" || touchedNode.parent?.name == "restartButton" {
            restartGame()
        }
    }
    
    private func restartGame() {
        // Create new GameScene
        let newGameScene = GameScene(size: size)
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(newGameScene, transition: transition)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        // Reposition elements when size changes
        if let gameOverLabel = children.first(where: { $0 is SKLabelNode }) as? SKLabelNode {
            gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 40)
        }
        
        restartButton?.position = CGPoint(x: size.width / 2, y: size.height / 2 - 40)
    }
}