//
//  VectorLike.swift
//
//
//  Created by li3zhen1 on 10/13/23.
//



/// A vector-like type that can be used in a `ForceSimulation`.
/// The members required by `VectorLike` are basically the same as `simd`'s `SIMD` protocol.
/// `NDTree` only rely on this protocol so that you can implement your structure on the platforms
/// that do not support `simd`.
public protocol VectorLike: CustomStringConvertible, Decodable, Encodable, ExpressibleByArrayLiteral, Hashable {
    
    
    associatedtype Scalar: FloatingPoint, Decodable, Encodable, Hashable, CustomDebugStringConvertible
    
    /// The length of the vector squared.
    /// This property should be implemented even if you are using `simd`.
    @inlinable func lengthSquared() -> Scalar

    /// The length of the vector.
    /// This property should be implemented even if you are using `simd`.
    @inlinable func length() -> Scalar

    /// The distance to another vector, squared.
    /// This property should be implemented even if you are using `simd`.
    @inlinable func distanceSquared(to: Self) -> Scalar

    /// The distance to another vector.
    /// This property should be implemented even if you are using `simd`.
    @inlinable func distance(to: Self) -> Scalar
    

    @inlinable static func * (a: Self, b: Double) -> Self
    @inlinable static func / (a: Self, b: Double) -> Self
    
    @inlinable static func * (a: Self, b: Scalar) -> Self
    @inlinable static func / (a: Self, b: Scalar) -> Self
    @inlinable static func - (a: Self, b: Self) -> Self
    @inlinable static func + (a: Self, b: Self) -> Self


    @inlinable static func + (a: Self, b: Scalar) -> Self
    
    @inlinable static func += (a: inout Self, b: Self)
    @inlinable static func -= (a: inout Self, b: Self)
    @inlinable static func *= (a: inout Self, b: Scalar)
    @inlinable static func /= (a: inout Self, b: Scalar)
    
    @inlinable static var scalarCount: Int { get }
    @inlinable static var zero: Self { get }

    init()

    subscript(index: Int) -> Self.Scalar { get set }
    
    var indices: Range<Int> { get }
}

