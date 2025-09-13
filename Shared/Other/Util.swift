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
    /// Wraps angle in radians to [0, 2π).
    var wrapAngle: CGFloat {
        let twoPi = 2 * CGFloat.pi
        let r = self.truncatingRemainder(dividingBy: twoPi)
        return r >= 0 ? r : r + twoPi
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

// MARK: - BaseToolbox-style extensions
extension CGFloat {
    func clamp(_ min: CGFloat, _ max: CGFloat) -> CGFloat {
        Swift.min(Swift.max(self, min), max)
    }
}

extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }
}

extension CGSize {
    static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }
}
