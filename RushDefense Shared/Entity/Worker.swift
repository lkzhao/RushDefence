//
//  MainCharacter.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/7/25.
//

class Worker: NodeEntity {
    override init() {
        super.init()
        entityType = [.ally, .worker]
        addComponent(MoveComponent())
        addComponent(WorkerVisualComponent())
        addComponent(AttackComponent())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
