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


public typealias Vector2d = simd_double2
public typealias Vector3d = simd_double3


public protocol CompactQuadTreeDelegate: NdTreeDelegate where Coordinate==Vector2d { }
public protocol CompactOctTreeDelegate: NdTreeDelegate where Coordinate==Vector3d { }


public typealias QuadBox = NdBox<Vector2d>
public typealias OctBox = NdBox<Vector3d>


public typealias CompactQuadTree<TD: CompactQuadTreeDelegate> = NdTree<Vector2d, TD>
public typealias CompactOctTree<TD: CompactOctTreeDelegate> = NdTree<Vector3d, TD>

#endif
