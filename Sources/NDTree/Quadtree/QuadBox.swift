//
//  _QuadBox.swift
//  
//
//  Created by li3zhen1 on 10/14/23.
//

import simd

/// A box in N-dimensional space.
/// - Note: `p0` is the minimum point of the box, `p1` is the maximum point of the box.
public struct _QuadBox {
    /// the minimum anchor of the box
    public var p0: simd_double2

    /// the maximum anchor of the box
    public var p1: simd_double2

    /// Create a box with 2 anchors.
    /// - Parameters:
    ///   - p0: anchor
    ///   - p1: another anchor in the diagonal position of `p0`
    /// - Note: `p0` you pass does not have to be minimum point of the box. 
    ///         `p1` does not have to be maximum point of the box. The initializer will
    ///         automatically adjust the order of `p0` and `p1` to make sure `p0` is the
    ///        minimum point of the box and `p1` is the maximum point of the box.
    @inlinable public init(p0: simd_double2, p1: simd_double2) {
        #if DEBUG
            assert(p0 != p1, "NdBox was initialized with 2 same anchor")
        #endif
        var p0 = p0
        var p1 = p1
        for i in p0.indices {
            if p1[i] < p0[i] {
                swap(&p0[i], &p1[i])
            }
        }
        self.p0 = p0
        self.p1 = p1
        // TODO: use Mask
    }

    /// Create a box with 2 anchors.
    /// - Parameters:
    ///   - pMin: minimum anchor of the box
    ///   - pMax: maximum anchor of the box
    /// - Note: Please make sure `pMin` is the minimum point of the box and `pMax` is the
    ///        maximum point of the box.
    @inlinable internal init(pMin: simd_double2, pMax: simd_double2) {
        #if DEBUG
            assert(pMin != pMax, "NdBox was initialized with 2 same anchor")
        #endif
        self.p0 = pMin
        self.p1 = pMax
    }

    /// Create a box with 2 zero anchors.
    @inlinable public init() {
        p0 = .zero
        p1 = .zero
    }

    /// Create a box with 2 anchors.
    /// - Parameters:
    ///   - p0: anchor
    ///   - p1: another anchor in the diagonal position of `p0`
    /// - Note: `p0` you pass does not have to be minimum point of the box. 
    ///         `p1` does not have to be maximum point of the box. The initializer will
    ///         automatically adjust the order of `p0` and `p1` to make sure `p0` is the
    ///        minimum point of the box and `p1` is the maximum point of the box.
    public init(_ p0: simd_double2, _ p1: simd_double2) {
        self.init(p0: p0, p1: p1)
    }

}

extension _QuadBox {
    @inlinable var diagnalVector: simd_double2 {
        return p1 - p0
    }

    @inlinable var center: simd_double2 { (p1 + p0) / Double(2) }

    /// Test if the box contains a point.
    /// - Parameter point: N dimensional point
    /// - Returns: `true` if the box contains the point, `false` otherwise.
    ///            The boundary test is similar to ..< operator.
    @inlinable func contains(_ point: simd_double2) -> Bool {
        for i in point.indices {
            if p0[i] > point[i] || point[i] >= p1[i] {
                return false
            }
        }
        return true
        //        return (p0 <= point) && (point < p1)
    }
}

extension _QuadBox {
    @inlinable func getCorner(of direction: Int) -> simd_double2 {
        var corner = simd_double2.zero
        for i in 0..<simd_double2.scalarCount {
            corner[i] = ((direction >> i) & 0b1) == 1 ? p1[i] : p0[i]
        }
        return corner
    }
    
    
    @inlinable public var debugDescription: String {
        return "[\(p0), \(p1)]"
    }
}


public extension _QuadBox {

    /// Get the small box that contains a list points and guarantees the box's size is at least 1x..x1.
    /// - Parameter points: The points to be covered.
    /// - Returns: The box that contains all the points.
    @inlinable static func cover(of points: [simd_double2]) -> Self {
        
        var _p0 = points[0]
        var _p1 = points[0]
        
        for p in points {
            for i in p.indices {
                if p[i] < _p0[i] {
                    _p0[i] = p[i]
                }
                if p[i] >= _p1[i] {
                    _p1[i] = p[i] + 1
                }
            }
        }
        
        #if DEBUG
        let _box = Self(_p0, _p1)
        assert(points.allSatisfy{ p in
            _box.contains(p)
        })
        #endif
        
        return Self(_p0, _p1)
    }
    
    /// Get the small box that contains a list points and guarantees the box's size is at least 1x..x1.
    /// Please note that KeyPath is slow.
    /// 
    /// - Parameter 
    ///  - points: The points to be covered.
    ///  - keyPath: The key path to get the vector from the point.
    /// - Returns: The box that contains all the points.
    @inlinable static func cover<T>(of points: [T], keyPath: KeyPath<T,simd_double2>) -> Self {
        
        var _p0 = points[0][keyPath: keyPath]
        var _p1 = points[0][keyPath: keyPath]
        
        for _p in points {
            let p = _p[keyPath: keyPath]
            for i in p.indices {
                if p[i] < _p0[i] {
                    _p0[i] = p[i]
                }
                if p[i] >= _p1[i] {
                    _p1[i] = p[i] + 1
                }
            }
        }
        
        #if DEBUG
        let _box = Self(_p0, _p1)
        assert(points.allSatisfy{ p in
            _box.contains(p[keyPath: keyPath])
        })
        #endif
        
        return Self(_p0, _p1)
    }
}

