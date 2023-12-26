// import simd

// protocol ViewportPoint<Scalar> {
//     associatedtype Scalar where Scalar: FloatingPoint
//     var x: Scalar { get }
//     var y: Scalar { get }
// }

// extension SIMD2: ViewportPoint where Scalar == Double {}

// public struct ViewportTransform {
//     public typealias Scalar = Double
//     @usableFromInline
//     internal var data: SIMD3<Scalar>

//     @inlinable
//     public init(data: SIMD3<Scalar>) {
//         self.data = data
//     }
// }

// extension ViewportTransform: ExpressibleByArrayLiteral {
//     @inlinable
//     public init(arrayLiteral elements: Scalar...) {
//         self.init(data: SIMD3<Scalar>(elements))
//     }
// }

// extension ViewportTransform {
//     @inlinable
//     public var k: Scalar {
//         return self.data.x
//     }

//     @inlinable
//     public var x: Scalar {
//         return self.data.y
//     }

//     @inlinable
//     public var y: Scalar {
//         return self.data.z
//     }
// }

// extension ViewportTransform {
//     @inlinable
//     public func scale(by factor: Scalar) -> ViewportTransform {
//         return ViewportTransform(data: self.data * [1, factor, factor])
//     }

//     @inlinable
//     public func translate(by vector: SIMD2<Scalar>) -> ViewportTransform {
//         return ViewportTransform(data: self.data + [0, vector.x, vector.y])
//     }
// }
