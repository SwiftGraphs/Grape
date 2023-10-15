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


public protocol CompactQuadTreeDelegate: NDTreeDelegate where V==Vector2d, Node==Int { }
public protocol CompactOctTreeDelegate: NDTreeDelegate where V==Vector3d, Node==Int { }


public typealias QuadBox = NDBox<Vector2d>
public typealias OctBox = NDBox<Vector3d>


public typealias CompactQuadTree<TD: CompactQuadTreeDelegate> = NDTree<Vector2d, TD>
public typealias CompactOctTree<TD: CompactOctTreeDelegate> = NDTree<Vector3d, TD>

#endif
