
/// A protocol for vectors that can be jiggled, and has a certain precision for
/// simulation — so zero vectors could be altered
/// into a small random non-zero vector, and then the force simulation could be
/// could be numerically stable.
public protocol SimulatableVector: SIMD
where Scalar: FloatingPoint & HasDeterministicRandomGenerator {
    @inlinable
    static var clusterDistance: Scalar { get }

    @inlinable
    static var clusterDistanceSquared: Scalar { get }

    @inlinable
    func jiggled(by: UnsafeMutablePointer<Scalar.Generator>) -> Self
}

// extension SimulatableVector {

//     /// If the vector is zero, returns a vector with the same magnitude as `self` but pointing in a random direction,
//     /// otherwise returns `self`.
//     @inlinable
//     public func jiggled() -> Self {
//         var result = Self.zero
//         for i in indices {
//             result[i] = self[i].jiggled()
//         }
//         return result
//     }
// }

/// A protocol for vectors that can be calculated with L2 norms, i.e. Euclidean distance.
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
        return clusterDistance * clusterDistance
    }

    @inlinable
    public func jiggled(by: UnsafeMutablePointer<Scalar.Generator>) -> Self {
        return .init(x: self.x.jiggled(by: by), y: self.y.jiggled(by: by))
    }
}

extension SIMD3: SimulatableVector where Scalar: FloatingPoint & HasDeterministicRandomGenerator {

    @inlinable
    public static var clusterDistance: Scalar {
        return 1e-5
    }

    @inlinable
    public static var clusterDistanceSquared: Scalar {
        return clusterDistance * clusterDistance
    }

    @inlinable
    public func jiggled(by: UnsafeMutablePointer<Scalar.Generator>) -> Self {
        return .init(
            x: self.x.jiggled(by: by), 
            y: self.y.jiggled(by: by), 
            z: self.z.jiggled(by: by)
        )
    }
}

#if canImport(simd)
import simd


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
        return simd_fast_length(self)
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
        return simd_fast_length(self)
    }
}

#endif
