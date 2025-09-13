//
//  ResourceManager.swift
//  RushDefense
//
//  Resource management system for tracking game resources like gold.
//

import Foundation

class ResourceManager {
    private(set) var gold: Int = 0
    
    func addGold(_ amount: Int) {
        gold += amount
    }
    
    @discardableResult
    func spendGold(_ amount: Int) -> Bool {
        guard gold >= amount else { return false }
        gold -= amount
        return true
    }
    
    var currentGold: Int {
        return gold
    }
}