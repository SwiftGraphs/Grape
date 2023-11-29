// TODO: https://forums.swift.org/t/deterministic-randomness-in-swift/20835/5

/// A random number generator that generates deterministic random numbers.
public protocol DeterministicRandomGenerator<Scalar> {
    associatedtype Scalar where Scalar: FloatingPoint & ExpressibleByFloatLiteral
    @inlinable static func next() -> Scalar
    @inlinable mutating func next() -> Scalar
    @inlinable init(seed: Scalar)
    @inlinable init()
}

/// A random number generator that generates deterministic random numbers for `Double`.
public struct DoubleLinearCongruentialGenerator: DeterministicRandomGenerator {
    @usableFromInline internal static let a: UInt32 = 1_664_525
    @usableFromInline internal static let c: UInt32 = 1_013_904_223
    @usableFromInline internal static var _s: UInt32 = 1
    @usableFromInline internal var s: UInt32 = 1

    @inlinable public mutating func next() -> Double {
        // Perform the linear congruential generation with integer arithmetic.
        // The overflow addition and multiplication automatically wrap around,
        // thus imitating the modulo operation.
        s = Self.a &* s &+ Self.c

        // Convert the result to Double and divide by m to normalize it.
        return Double(s) / 4_294_967_296.0
    }

    @inlinable public static func next() -> Double {
        
        Self._s = Self.a &* Self._s &+ Self.c

        // Convert the result to Double and divide by m to normalize it.
        return Double(Self._s) / 4_294_967_296.0
    }

    @inlinable public init(seed: Double) {
        self.s = 1 //seed
    }

    @inlinable public init() {
        self.init(seed: 1)
    }
}

/// A random number generator that generates deterministic random numbers for `Float`.
public struct FloatLinearCongruentialGenerator: DeterministicRandomGenerator {

    @usableFromInline internal static let a: UInt16 = 75
    @usableFromInline internal static let c: UInt16 = 74
    @usableFromInline internal static var _s: UInt16 = 1
    @usableFromInline internal var s: UInt16 = 1

    @inlinable public mutating func next() -> Float {
        // Perform the linear congruential generation with integer arithmetic.
        // The overflow addition and multiplication automatically wrap around.
        s = Self.a &* s &+ Self.c

        // Convert the result to Float and divide by m to normalize it.
        return Float(s) / 65537.0
    }

    @inlinable public static func next() -> Float {
        _s = a &* _s &+ c

        // Convert the result to Float and divide by m to normalize it.
        return Float(_s) / 65537.0
    }

    @inlinable public init(seed: Float) {
        self.s = 1 //seed
    }

    @inlinable public init() {
        self.init(seed: 1)
    }
}


/// A floating point type that can be generated with a deterministic random number generator ``DeterministicRandomGenerator``.
public protocol HasDeterministicRandomGenerator: FloatingPoint & ExpressibleByFloatLiteral {
    associatedtype Generator: DeterministicRandomGenerator where Generator.Scalar == Self
}

extension Double: HasDeterministicRandomGenerator {
    public typealias Generator = DoubleLinearCongruentialGenerator
}

extension Float: HasDeterministicRandomGenerator {
    public typealias Generator = FloatLinearCongruentialGenerator
}

extension HasDeterministicRandomGenerator {
    @inlinable
    public func jiggled() -> Self {
        if self == .zero || self == .nan {
            return (Generator.next() - 0.5) * 1e-5
        }
        return self
    }

    @inlinable
    public func jiggled(by: UnsafeMutablePointer<Generator>) -> Self {
        if self == .zero || self == .nan {
            return (by.pointee.next() - 0.5) * 1e-5
        }
        return self
    }
}
