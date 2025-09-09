//
//  Map.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/7/25.
//

import SpriteKit
import GameplayKit

class Map: SKNode {
    let tileMap: SKTileMapNode
    let baseMap: SKTileMapNode
    let columns: Int
    let rows: Int
    let tileSize: CGSize

    /// Initialize a map with the given grid dimensions.
    /// Uses `MapTileSet.sks` and fills with Perlin noise: Sand if height >= 0, Base otherwise.
    init(columns: Int, rows: Int, seed: Int32 = Int32.random(in: 0...Int32.max)) {
        guard let tileSet = SKTileSet(named: "MapTileSet") else {
            fatalError("MapTileSet.sks not found in bundle")
        }

        self.columns = columns
        self.rows = rows
        self.tileSize = tileSet.defaultTileSize
        self.tileMap = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSet.defaultTileSize)
        self.tileMap.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.baseMap = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSet.defaultTileSize)
        self.baseMap.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        super.init()

        addChild(baseMap)
        addChild(tileMap)

        // Prepare tiles
        let sand = tileSet.tileGroups.first(where: { $0.name == "Sand" })
        let base = tileSet.tileGroups.first(where: { $0.name == "Base" })

        baseMap.fill(with: base)
        tileMap.fill(with: sand)

//        // Noise setup (Perlin)
//        let source = GKPerlinNoiseSource(frequency: 0.8, octaveCount: 6, persistence: 0.5, lacunarity: 2.0, seed: seed)
//        let noise = GKNoise(source)
//
//        // Scale the noise so that we get nicely varying features across the map
//        let sampleCount = vector_int2(Int32(columns), Int32(rows))
//        let noiseSize = vector_double2(1.5, 1.5)
//        let origin = vector_double2(0.0, 0.0)
//        let noiseMap = GKNoiseMap(noise,
//                                  size: noiseSize,
//                                  origin: origin,
//                                  sampleCount: sampleCount,
//                                  seamless: true)
//
//        for row in 0..<rows {
//            for col in 0..<columns {
//                let value = noiseMap.value(at: vector_int2(Int32(col), Int32(row)))
//                if value >= -0.5 {
//                    if let g = sand { tileMap.setTileGroup(g, forColumn: col, row: row) }
//                }
//            }
//        }
    }

    /// Convenience initializer to cover a pixel size area.
    convenience init(sizeInPoints: CGSize, seed: Int32 = Int32.random(in: 0...Int32.max)) {
        guard let tileSet = SKTileSet(named: "MapTileSet") else {
            fatalError("MapTileSet.sks not found in bundle")
        }
        let tile = tileSet.defaultTileSize
        let cols = max(1, Int(ceil(sizeInPoints.width / tile.width)))
        let rows = max(1, Int(ceil(sizeInPoints.height / tile.height)))
        self.init(columns: cols, rows: rows, seed: seed)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
