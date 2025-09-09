//
//  EntityType.swift
//  RushDefense
//
//  Bitmask types for entities to categorize interactions.
//

import Foundation

struct EntityType: OptionSet {
    let rawValue: UInt8

    init(rawValue: UInt8) { self.rawValue = rawValue }

    static let enemy    = EntityType(rawValue: 1 << 0)
    static let ally     = EntityType(rawValue: 1 << 1)
    static let building = EntityType(rawValue: 1 << 2)
    static let worker   = EntityType(rawValue: 1 << 3)
}

