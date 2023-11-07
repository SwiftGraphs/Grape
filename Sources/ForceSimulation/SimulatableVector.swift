import simd

public protocol SimulatableVector: SIMD
where Scalar: FloatingPoint & HasDeterministicRandomGenerator {
    @inlinable
    static var clusterDistance: Scalar { get }

    @inlinable
    static var clusterDistanceSquared: Scalar { get }
}

extension SimulatableVector {
    @inlinable
    public func jiggled() -> Self {
        var result = Self.zero
        for i in indices {
            result[i] = self[i].jiggled()
        }
        return result
    }
}

public protocol L2NormCalculatable: SIMD where Scalar: FloatingPoint {
    @inlinable
    func distanceSquared(to point: Self) -> Scalar

    @inlinable
    func distance(to point: Self) -> Scalar

    @inlinable
    func lengthSquared() -> Scalar

    @inlinable
    func length() -> Scalar
}

extension SIMD2: SimulatableVector where Scalar: FloatingPoint & HasDeterministicRandomGenerator {

    @inlinable
    public static var clusterDistance: Scalar {
        return 1e-5
    }

    @inlinable
    public static var clusterDistanceSquared: Scalar {
        return 1e-10
    }
}

extension SIMD3: SimulatableVector where Scalar: FloatingPoint & HasDeterministicRandomGenerator {

    @inlinable
    public static var clusterDistance: Scalar {
        return 1e-5
    }

    @inlinable
    public static var clusterDistanceSquared: Scalar {
        return 1e-10
    }
}

extension SIMD2: L2NormCalculatable where Scalar == Double {
    @inlinable
    public func distanceSquared(to point: SIMD2<Scalar>) -> Scalar {
        return simd_distance_squared(self, point)
    }

    @inlinable
    public func distance(to point: SIMD2<Scalar>) -> Scalar {
        return simd_distance(self, point)
    }

    @inlinable
    public func lengthSquared() -> Scalar {
        return simd_length_squared(self)
    }

    @inlinable
    public func length() -> Scalar {
        return simd_length(self)
    }
}

extension SIMD3: L2NormCalculatable where Scalar == Float {
    @inlinable
    public func distanceSquared(to point: SIMD3<Scalar>) -> Scalar {
        return simd_distance_squared(self, point)
    }

    @inlinable
    public func distance(to point: SIMD3<Scalar>) -> Scalar {
        return simd_distance(self, point)
    }

    @inlinable
    public func lengthSquared() -> Scalar {
        return simd_length_squared(self)
    }

    @inlinable
    public func length() -> Scalar {
        return simd_length(self)
    }
}
