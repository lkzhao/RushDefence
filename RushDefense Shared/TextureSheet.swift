//
//  TextureSheet.swift
//  RushDefense
//
//  Shared protocol and helpers for slicing sprite sheets.
//

import SpriteKit

protocol TextureSheetProvider {
    /// Name of the base image asset (a horizontal strip of square frames).
    var assetName: String { get }
}

fileprivate var cache: [String: [SKTexture]] = [:]

extension TextureSheetProvider {
    /// Sliced frames from the sheet specified by `assetName`.
    /// Assumes a horizontal strip of square frames (frameWidth == frameHeight).
    var textures: [SKTexture] {
        let key = assetName
        if let cached = cache[key] { return cached }

        let base = SKTexture(imageNamed: key)
        base.filteringMode = .nearest
        let size = base.size()
        // Derive columns by width/height ratio, clamp to at least 1.
        let columns = max(1, Int(round(size.width / max(1, size.height))))
        let w = 1.0 / CGFloat(columns)
        let frames: [SKTexture] = (0..<columns).map { i in
            let rect = CGRect(x: CGFloat(i) * w, y: 0, width: w, height: 1)
            let tex = SKTexture(rect: rect, in: base)
            tex.filteringMode = .nearest
            return tex
        }
        cache[key] = frames
        return frames
    }
}
