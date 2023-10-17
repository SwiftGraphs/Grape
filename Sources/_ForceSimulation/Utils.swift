//
//  File.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//
import NDTree

// TODO: impl deterministic random number generator
// https://forums.swift.org/t/deterministic-randomness-in-swift/20835/5
public struct LinearCongruentialGenerator {
    @usableFromInline internal static let a: Double = 1664525
    @usableFromInline internal static let c: Double = 1013904223
    @usableFromInline internal static let m: Double = 4294967296
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

public extension Double {
    @inlinable func jiggled() -> Double {
        if self == 0 || self == .nan {
            return (LinearCongruentialGenerator.next() - 0.5) * 1e-6
        }
        return self
    }
}

public extension VectorLike where Scalar == Double {
    @inlinable func jiggled() -> Self {
        var result = Self.zero
        for i in indices {
            result[i] = self[i].jiggled()
        }
        return result
    }
}

