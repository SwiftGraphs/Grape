//
//  Utils.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//




// TODO: https://forums.swift.org/t/deterministic-randomness-in-swift/20835/5

/// A random number generator that generates deterministic random numbers.
public struct LinearCongruentialGenerator {
    @usableFromInline internal static let a: Double = 1_664_525
    @usableFromInline internal static let c: Double = 1_013_904_223
    @usableFromInline internal static let m: Double = 4_294_967_296
    @usableFromInline internal static var _s: Double = 1
    @usableFromInline internal var s: Double = 1

    @inlinable mutating func next() -> Double {
        s = (Self.a * s + Self.c).truncatingRemainder(dividingBy: Self.m)
        return s / Self.m
    }

    @inlinable static func next() -> Double {
        Self._s = (Self.a * Self._s + Self.c).truncatingRemainder(dividingBy: Self.m)
        return Self._s / Self.m
    }
}

public struct FloatLinearCongruentialGenerator {
    @usableFromInline internal static let a: Float = 75
    @usableFromInline internal static let c: Float = 74
    @usableFromInline internal static let m: Float = 65537
    @usableFromInline internal static var _s: Float = 1
    @usableFromInline internal var s: Float = 1

    @inlinable mutating func next() -> Float {
        s = (Self.a * s + Self.c).truncatingRemainder(dividingBy: Self.m)
        return s / Self.m
    }

    @inlinable static func next() -> Float {
        Self._s = (Self.a * Self._s + Self.c).truncatingRemainder(dividingBy: Self.m)
        return Self._s / Self.m
    }
}

public protocol SimulatableFloatingPoint: ExpressibleByFloatLiteral {
    func jiggled() -> Self
}

extension Double: SimulatableFloatingPoint {
    @inlinable public func jiggled() -> Double {
        if self == 0 || self == .nan {
            // return Double.random(in: -5e-6..<5e-6)
            return (LinearCongruentialGenerator.next() - 0.5) * 1e-5
        }
        return self
    }
}

extension Float: SimulatableFloatingPoint {
    @inlinable public func jiggled() -> Float {
        if self == 0 || self == .nan {
            // return Double.random(in: -5e-6..<5e-6)
            return (FloatLinearCongruentialGenerator.next() - 0.5) * 1e-5
        }
        return self
    }
}


#if canImport(simd)

import simd
extension simd_double2 {
    @inlinable public func jiggled() -> Self {
        var result = Self.zero
        for i in indices {
            result[i] = self[i].jiggled()
        }
        return result
    }
}

extension simd_float3 {
    @inlinable public func jiggled() -> Self {
        var result = Self.zero
        for i in indices {
            result[i] = self[i].jiggled()
        }
        return result
    }
}

#endif

extension VectorLike where Scalar: SimulatableFloatingPoint {
    @inlinable public func jiggled() -> Self {
        var result = Self.zero
        for i in indices {
            result[i] = self[i].jiggled()
        }
        return result
    }
}


/// A Hashable identifier for an edge. It’s a utility type for preserving the
/// `Hashable` conformance.
public struct EdgeID<NodeID>: Hashable where NodeID: Hashable {
    public let source: NodeID
    public let target: NodeID

    public init(_ source: NodeID, _ target: NodeID) {
        self.source = source
        self.target = target
    }
}
