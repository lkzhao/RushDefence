//
//  MainCharacter.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/7/25.
//

class Worker: Entity {
    override init() {
        super.init()
        entityType = [.ally, .worker]
        collisionRadius = 12
        addComponent(MoveComponent())
        addComponent(WorkerVisualComponent())
//        addComponent(AttackComponent())
    }
}
