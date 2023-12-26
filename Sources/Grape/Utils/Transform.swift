public protocol TransformProtocol {
    associatedtype Scalar: FloatingPoint & ExpressibleByFloatLiteral
    associatedtype Vector: SIMD where Vector.Scalar == Scalar
    var translate: Vector { get set }
    var scale: Scalar { get set }
    init(translate: Vector, scale: Scalar)
}

extension TransformProtocol {

    @inlinable
    public static var identity: Self {
        return Self(translate: .zero, scale: 1)
    }
    
    @inlinable
    public func apply(to point: Vector) -> Vector {
        return point * scale + translate
    }

    @inlinable
    public func invert(_ point: Vector) -> Vector {
        return (point - translate) / scale
    }

    @inlinable
    public func apply(to points: [Vector]) -> [Vector] {
        return points.map(apply)
    }

    @inlinable
    public func translate(by delta: Vector) -> Self {
        return Self(translate: translate + delta, scale: scale)
    }

    @inlinable
    public func translate(to point: Vector) -> Self {
        return Self(translate: point, scale: scale)
    }

    @inlinable
    public mutating func translating(by delta: Vector) {
        // self = Self(translate: translate + delta, scale: scale)
        self.translate = translate + delta
    }

    @inlinable
    public mutating func translating(to point: Vector) {
        // self = Self(translate: point, scale: scale)
        self.translate = point
    }

    @inlinable
    public func scale(by delta: Scalar) -> Self {
        return Self(translate: translate, scale: scale + delta)
    }

    @inlinable
    public func scale(to factor: Scalar) -> Self {
        return Self(translate: translate, scale: factor)
    }

    @inlinable
    public mutating func scaling(by delta: Scalar) {
        // self = Self(translate: translate, scale: scale * delta)
        self.scale = scale * delta
    }

    @inlinable
    public mutating func scaling(to factor: Scalar) {
        // self = Self(translate: translate, scale: factor)
        self.scale = factor
    }

}

public struct ViewportTransform: TransformProtocol {
    public typealias Scalar = Double

    public var translate: SIMD2<Scalar>

    public var scale: Scalar

    @inlinable
    public init(translate: SIMD2<Scalar>, scale: Scalar) {
        self.translate = translate
        self.scale = scale
    }
}

public struct VolumeTransform: TransformProtocol {
    public typealias Scalar = Double

    // TODO: translate wastes 1 lane,
    // combine translate and scale into a single SIMD4?
    public var translate: SIMD3<Scalar>

    public var scale: Scalar

    @inlinable
    public init(translate: SIMD3<Scalar>, scale: Scalar) {
        self.translate = translate
        self.scale = scale
    }
}

#if canImport(SwiftUI)

    import SwiftUI

    extension ViewportTransform {
        @inlinable
        public func toCGAffineTransform() -> CGAffineTransform {
            return CGAffineTransform(
                a: CGFloat(scale),
                b: 0,
                c: 0,
                d: CGFloat(scale),
                tx: CGFloat(translate.x),
                ty: CGFloat(translate.y)
            )
        }

        @inlinable
        public func fromCGAffineTransform(_ transform: CGAffineTransform) -> Self {
            return Self(
                translate: .init(x: Scalar(transform.tx), y: Scalar(transform.ty)),
                scale: Scalar(transform.a)
            )
        }

    }

#endif
