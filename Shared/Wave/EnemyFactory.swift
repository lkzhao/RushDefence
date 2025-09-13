//
//  EnemyFactory.swift
//  RushDefense
//
//  Centralized enemy creation factory
//

import Foundation

class EnemyFactory {
    static func createEnemy(of type: EnemyType) -> Entity {
        switch type {
        case .bear:
            return Bear()
        case .gnome:
            return Gnome()
        case .lancer:
            return Lancer()
        case .shaman:
            return Shaman()
        case .skull:
            return Skull()
        case .lizard:
            return Lizard()
        case .snake:
            return Snake()
        case .spider:
            return Spider()
        case .thief:
            return Thief()
        case .gnoll:
            return Gnoll()
        case .boat:
            return Boat()
        case .harpoonFish:
            return HarpoonFish()
        case .minotaur:
            return Minotaur()
        case .paddleFish:
            return PaddleFish()
        case .panda:
            return Panda()
        case .turtle:
            return Turtle()
        case .troll:
            return Troll()
        }
    }
}