//
//  Util.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

import Foundation

// MARK: - CGPoint vector helpers
extension CGPoint {
    /// Unit-length vector in the same direction, or `.zero` when length is zero.
    func normalized() -> CGPoint {
        let len = length
        guard len > 0 else { return .zero }
        return self / len
    }

    /// Returns this vector clamped to a maximum magnitude.
    func clampedMagnitude(to maxLength: CGFloat) -> CGPoint {
        let len = length
        guard len > maxLength && len > 0 else { return self }
        return self / len * maxLength
    }
}

extension CGFloat {
    /// Wraps angle in radians to [0, 2π].
    var wrapAngle: CGFloat {
        var a = self
        while a < 0 { a += 2 * .pi }
        while a >= 2 * .pi { a -= 2 * .pi }
        return a
    }
}

extension CGPoint {
    var float2: SIMD2<Float> {
        SIMD2<Float>(Float(x), Float(y))
    }

    var length: CGFloat {
        hypot(x, y)
    }

    var angle: CGFloat {
        atan2(y, x)
    }
}

extension SIMD2<Float> {
    var cgPoint: CGPoint {
        CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}
