public struct simd_float2 {
    public var x: Float
    public var y: Float

    public init(_ v0: Float, _ v1: Float) {
        self.x = v0
        self.y = v1
    }

    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
}

extension simd_float2: AdditiveArithmetic {
    @inlinable public static func + (lhs: simd_float2, rhs: simd_float2) -> simd_float2 {
        return simd_float2(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    @inlinable public static func - (lhs: simd_float2, rhs: simd_float2) -> simd_float2 {
        return simd_float2(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    @inlinable public static func += (lhs: inout simd_float2, rhs: simd_float2) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }

    @inlinable public static func -= (lhs: inout simd_float2, rhs: simd_float2) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }

    @inlinable public static var zero: simd_float2 {
        return simd_float2(0, 0)
    }
}

extension simd_float2: DurationProtocol {
    public static func / (lhs: simd_float2, rhs: Int) -> simd_float2 {
        return simd_float2(lhs.x / Float(rhs), lhs.y / Float(rhs))
    }

    public static func * (lhs: simd_float2, rhs: Int) -> simd_float2 {
        return simd_float2(lhs.x * Float(rhs), lhs.y * Float(rhs))
    }

    public static func / (lhs: simd_float2, rhs: simd_float2) -> Double {
        return Double(lhs.x / rhs.x + lhs.y / rhs.y)
    }

    public static func < (lhs: simd_float2, rhs: simd_float2) -> Bool {
        return lhs.x < rhs.x && lhs.y < rhs.y
    }
}
