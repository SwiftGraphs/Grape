//
//  simd+VectorLike.swift
//
//
//  Created by li3zhen1 on 10/13/23.
//

#if canImport(simd)

import simd

extension simd_double2: VectorLike {
    @inlinable public func lengthSquared() -> Scalar {
        return simd_length_squared(self)
    }

    @inlinable public func length() -> Scalar {
        return simd_length(self)
    }

    @inlinable public func distanceSquared(to: SIMD2<Scalar>) -> Scalar {
        return simd_length_squared(self - to)
    }

    @inlinable public func distance(to: SIMD2<Scalar>) -> Scalar {
        return simd_length(self - to)
    }

}

extension simd_float3: VectorLike {

    @inlinable public func lengthSquared() -> Scalar {
        return simd_length_squared(self)
    }

    @inlinable public func length() -> Scalar {
        return simd_length(self)
    }

    @inlinable public func distanceSquared(to: SIMD3<Scalar>) -> Scalar {
        return simd_length_squared(self - to)
    }

    @inlinable public func distance(to: SIMD3<Scalar>) -> Scalar {
        return simd_length(self - to)
    }

}

public typealias QuadBox = NDBox<simd_double2>
public typealias OctBox = NDBox<simd_float3>

#endif