//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/14/23.
//

public struct NDBox<V> where V: VectorLike {
    public var p0: V
    public var p1: V

    @inlinable public init(p0: V, p1: V) {
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

    @inlinable internal init(pMin: V, pMax: V) {
        #if DEBUG
            assert(pMin != pMax, "NdBox was initialized with 2 same anchor")
        #endif
        self.p0 = pMin
        self.p1 = pMax
    }

    @inlinable public init() {
        p0 = .zero
        p1 = .zero
    }

    public init(_ p0: V, _ p1: V) {
        self.init(p0: p0, p1: p1)
    }

}

extension NDBox {
    @inlinable var area: V.Scalar {
        var result: V.Scalar = 1
        let delta = p1 - p0
        for i in delta.indices {
            result *= delta[i]
        }
        return result
    }

    @inlinable var vec: V { p1 - p0 }

    @inlinable var center: V { (p1 + p0) / V.Scalar(2) }

    @inlinable func contains(_ point: V) -> Bool {
        for i in point.indices {
            if p0[i] > point[i] || point[i] >= p1[i] {
                return false
            }
        }
        return true
        //        return (p0 <= point) && (point < p1)
    }
}

extension NDBox {
    @inlinable func getCorner(of direction: Int) -> V {
        var corner = V.zero
        for i in 0..<V.scalarCount {
            corner[i] = ((direction >> i) & 0b1) == 1 ? p1[i] : p0[i]
        }
        return corner
    }
    
    
    @inlinable public var debugDescription: String {
        return "[\(p0), \(p1)]"
    }
        
}
