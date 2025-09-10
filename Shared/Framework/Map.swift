//
//  Map.swift
//  RushDefense
//

import SpriteKit

// MARK: - Grid Types
struct GridLocation: Hashable { let x: Int; let y: Int }
struct GridSize: Equatable { let w: Int; let h: Int }
struct GridRect: Equatable {
    let origin: GridLocation
    let size: GridSize

    init(origin: GridLocation, size: GridSize) {
        self.origin = origin
        self.size = size
    }
    init(x: Int, y: Int, w: Int, h: Int) {
        self.origin = GridLocation(x: x, y: y)
        self.size = GridSize(w: w, h: h)
    }
}

// MARK: - Grid helpers (value types)
extension GridLocation {
    func offset(dx: Int, dy: Int) -> GridLocation { GridLocation(x: x + dx, y: y + dy) }
}

extension GridSize {
    static let one = GridSize(w: 1, h: 1)
    var area: Int { w * h }
    var isPositive: Bool { w > 0 && h > 0 }
}

extension GridRect {
    var minX: Int { origin.x }
    var minY: Int { origin.y }
    var maxXExclusive: Int { origin.x + size.w }
    var maxYExclusive: Int { origin.y + size.h }
    func contains(_ loc: GridLocation) -> Bool {
        loc.x >= minX && loc.y >= minY && loc.x < maxXExclusive && loc.y < maxYExclusive
    }
    func contains(_ rect: GridRect) -> Bool {
        rect.minX >= minX && rect.minY >= minY && rect.maxXExclusive <= maxXExclusive && rect.maxYExclusive <= maxYExclusive
    }
    func locations() -> [GridLocation] {
        guard size.isPositive else { return [] }
        var out: [GridLocation] = []
        out.reserveCapacity(size.area)
        for y in minY..<maxYExclusive { for x in minX..<maxXExclusive { out.append(GridLocation(x: x, y: y)) } }
        return out
    }
}

class Map {
    let node = SKNode()
    let terrain: BaseTerrain
    let columns: Int
    let rows: Int
    let cellSize: CGSize

    private(set) var entities: [Entity] = []
    private var occupied: [GridLocation: Entity] = [:]

    private(set) var zoom: CGFloat = 1.0 {
        didSet {
            node.xScale = zoom
            node.yScale = zoom
        }
    }

    // Dynamic zoom limits, to be set by GameScene
    var minimumZoom: CGFloat = 0.25
    var maximumZoom: CGFloat = 4.0

    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        self.terrain = BaseTerrain(columns: columns, rows: rows)
        self.cellSize = terrain.tileSize
        terrain.zPosition = -1
        node.addChild(terrain)
    }

    // MARK: - Entity Management
    func addEntity(_ entity: Entity) {
        guard !entities.contains(where: { $0 === entity }) else { return }
        entities.append(entity)
        entity.map = self
        node.addChild(entity.node)
        entity.didAddToMap(self)
    }

    func removeEntity(_ entity: Entity) {
        if let idx = entities.firstIndex(where: { $0 === entity }) {
            let removed = entities.remove(at: idx)
            removed.willRemoveFromMap(self)
            removed.node.removeFromParent()
            removed.map = nil
            // Free occupied cells for this entity
            let toRemove = occupied.filter { $0.value === removed }.map { $0.key }
            for key in toRemove { occupied.removeValue(forKey: key) }
        }
    }

    func update(deltaTime seconds: TimeInterval) {
        for e in entities { e.update(deltaTime: seconds) }
    }

    // MARK: - Grid helpers
    var gridBounds: GridRect { GridRect(x: 0, y: 0, w: columns, h: rows) }
    func isOccupied(at location: GridLocation) -> Bool { occupied[location] != nil }

    func centerPointFor(location: GridLocation) -> CGPoint {
        return centerPointFor(rect: GridRect(origin: location, size: .one))
    }

    func centerPointFor(rect: GridRect) -> CGPoint {
        let totalW = CGFloat(columns) * cellSize.width
        let totalH = CGFloat(rows) * cellSize.height
        let px = (CGFloat(rect.origin.x) + CGFloat(rect.size.w) * 0.5) * cellSize.width - totalW / 2
        let py = (CGFloat(rect.origin.y) + CGFloat(rect.size.h) * 0.5) * cellSize.height - totalH / 2
        return CGPoint(x: px, y: py)
    }

    func grid(for point: CGPoint) -> GridLocation {
        let totalW = CGFloat(columns) * cellSize.width
        let totalH = CGFloat(rows) * cellSize.height
        let gx = Int(floor((point.x + totalW / 2) / cellSize.width))
        let gy = Int(floor((point.y + totalH / 2) / cellSize.height))
        return GridLocation(x: gx, y: gy)
    }

    // MARK: - Placement
    @discardableResult
    func placeBuilding(_ entity: Entity, at location: GridLocation) -> Bool {
        let rect = GridRect(origin: location, size: entity.gridSize)
        guard gridBounds.contains(rect), isFree(rect) else { return false }
        occupy(rect, with: entity)
        entity.node.position = centerPointFor(rect: rect)
        addEntity(entity)
        return true
    }

    @discardableResult
    func placeBuilding(_ entity: Entity, at point: CGPoint) -> Bool {
        placeBuilding(entity, at: grid(for: point))
    }

    // MARK: - Queries
    func entityAt(location: GridLocation) -> Entity? { occupied[location] }
    func entityAt(point: CGPoint) -> Entity? { occupied[grid(for: point)] }

    // MARK: - Occupancy helpers
    func isFree(_ rect: GridRect) -> Bool {
        for loc in rect.locations() { if occupied[loc] != nil { return false } }
        return true
    }
    func occupy(_ rect: GridRect, with entity: Entity) {
        for loc in rect.locations() { occupied[loc] = entity }
    }

    // MARK: - Zoom
    func setZoom(_ value: CGFloat) {
        zoom = value.clamp(minimumZoom, maximumZoom)
    }
}
