//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/13/23.
//

public protocol VectorLike {
    associatedtype Scalar: FloatingPoint
    @inlinable func lengthSquared() -> Scalar
    @inlinable func length() -> Scalar
    @inlinable func distanceSquared(to: Self) -> Scalar
    @inlinable func distance(to: Self) -> Scalar
}
