//
//  CoreGraphics+SIMD.swift
//
//
//  Created by li3zhen1 on 12/13/23.
//

import SwiftUI
//#if canImport(SwiftUI) && canImport(simd)
import simd

extension CGPoint {
    @inlinable
    internal var simd: SIMD2<Double> {
        return SIMD2<Double>(x: x, y: y)
    }
}

extension CGSize {
    @inlinable
    internal var simd: SIMD2<Double> {
        return SIMD2<Double>(x: width, y: height)
    }
}

extension SIMD2 where Scalar == Double {
    @inlinable
    internal var cgPoint: CGPoint {
        return CGPoint(x: x, y: y)
    }

    @inlinable
    internal var cgSize: CGSize {
        return CGSize(width: x, height: y)
    }
}

//#endif
