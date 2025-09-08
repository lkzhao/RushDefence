//
//  TextureSheet.swift
//  RushDefense
//
//  Shared protocol and helpers for slicing sprite sheets.
//

import SpriteKit

class TextureCache {
    static let shared = TextureCache()
    private init() {}

    private var cache: [String: [SKTexture]] = [:]

    func textures(for assetName: String) -> [SKTexture] {
        if let cached = cache[assetName] { return cached }

        let base = SKTexture(imageNamed: assetName)
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
        cache[assetName] = frames
        return frames
    }
}

protocol TextureSheetProvider {
    /// Name of the base image asset (a horizontal strip of square frames).
    var assetName: String { get }
}

extension TextureSheetProvider {
    /// Sliced frames from the sheet specified by `assetName`.
    /// Assumes a horizontal strip of square frames (frameWidth == frameHeight).
    var textures: [SKTexture] {
        TextureCache.shared.textures(for: assetName)
    }
}
