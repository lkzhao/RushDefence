//
//  GoldGenerationComponent.swift
//  RushDefense
//
//  Component that periodically generates gold and adds it to the resource manager.
//

class GoldGenerationComponent: Component {
    let goldAmount: Int
    let generationInterval: TimeInterval
    var timeSinceLastGeneration: TimeInterval = 0
    
    init(goldAmount: Int = 100, generationInterval: TimeInterval = 3.0) {
        self.goldAmount = goldAmount
        self.generationInterval = generationInterval
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        timeSinceLastGeneration += seconds
        if timeSinceLastGeneration >= generationInterval {
            timeSinceLastGeneration = 0
            generateGold()
        }
    }
    
    private func generateGold() {
        guard let map = entity?.map else { return }
        map.resourceManager.addGold(goldAmount)
    }
}