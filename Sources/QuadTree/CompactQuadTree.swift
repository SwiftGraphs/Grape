//
//  File 2.swift
//  
//
//  Created by li3zhen1 on 10/13/23.
//

#if canImport(simd)

import simd
extension simd_double2: VectorLike {

    
    @inlinable public func distanceSquared(to: SIMD2<Scalar>) -> Scalar {
        return (self-to).lengthSquared()
    }
    
    @inlinable public func distance(to: SIMD2<Scalar>) -> Scalar {
        return (self-to).length()
    }
}

extension simd_double3: VectorLike {
    @inlinable public func distanceSquared(to: SIMD3<Scalar>) -> Scalar {
        return (self-to).lengthSquared()
    }
    
    @inlinable public func distance(to: SIMD3<Scalar>) -> Scalar {
        return (self-to).length()
    }
}

public typealias CompactQuadTree<TD: NdTreeDelegate> = CompactNdTree<simd_double2, TD>
public typealias QuadBox = NdBox<simd_double2>
public typealias CompactOctTree<TD: NdTreeDelegate> = CompactNdTree<simd_double3, TD>
public typealias OctBox = NdBox<simd_double3>

#endif
