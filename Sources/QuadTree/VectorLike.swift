//
//  VectorLike.swift
//
//
//  Created by li3zhen1 on 10/13/23.
//

public protocol VectorLike: CustomStringConvertible, Decodable, Encodable, ExpressibleByArrayLiteral, Hashable, AdditiveArithmetic {
    
    associatedtype Scalar: FloatingPoint, Decodable, Encodable, Hashable
    
    
    @inlinable func lengthSquared() -> Scalar
    @inlinable func length() -> Scalar
    @inlinable func distanceSquared(to: Self) -> Scalar
    @inlinable func distance(to: Self) -> Scalar
    
    static func * (a: Self, b: Scalar) -> Self
    static func / (a: Self, b: Scalar) -> Self
    
    /// the same members as simd
    static var scalarCount: Int { get }

    init()

    subscript(index: Int) -> Self.Scalar { get set }
    
    var indices: Range<Int> { get }
}
