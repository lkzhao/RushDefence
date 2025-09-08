//
//  Util.swift
//  RushDefense iOS
//
//  Created by Luke Zhao on 9/8/25.
//

import Foundation

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

extension GKGraphNode2D {
    var point: CGPoint {
        CGPoint(x: CGFloat(position.x), y: CGFloat(position.y))
    }
}

extension SIMD2<Float> {
    var cgPoint: CGPoint {
        CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}
