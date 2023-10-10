//
//  Quad.swift
//
//
//  Created by li3zhen1 on 9/26/23.
//
// #if arch(wasm32)
// import SimdPolyfill
// #else
import simd

// #endif

public typealias Vector3f = simd_float3

extension Vector3f: AdditiveArithmetic {

    @inlinable public func lengthSquared() -> Float {
        return x * x + y * y + z * z
    }

    @inlinable public func length() -> Float {
        return (x * x + y * y + z * z).squareRoot()
    }

    @inlinable public func squaredDistanceTo(_ point: Self) -> Float {
        return (self - point).lengthSquared()
    }

    @inlinable public func distanceTo(_ point: Self) -> Float {
        return (self - point).length()
    }
}

public struct Octad {
    public typealias Coordinate = simd_float3

    private var x0y0z0: Coordinate
    private var x1y1z1: Coordinate

    public var x0: Float {
        get {
            x0y0z0.x
        }
        set {
            x0y0z0.x = newValue
        }
    }

    public var x1: Float {
        get {
            x1y1z1.x
        }
        set {
            x1y1z1.x = newValue
        }
    }

    public var y0: Float {
        get {
            x0y0z0.y
        }
        set {
            x0y0z0.y = newValue
        }
    }

    public var y1: Float {
        get {
            x1y1z1.y
        }
        set {
            x1y1z1.y = newValue
        }
    }

        public var z0: Float {
        get {
            x0y0z0.z
        }
        set {
            x0y0z0.z = newValue
        }
    }

        public var z1: Float {
        get {
            x1y1z1.z
        }
        set {
            x1y1z1.z = newValue
        }
    }

    private init(x0y0z0: Coordinate, x1y1z1: Coordinate) {
        self.x0y0z0 = x0y0z0
        self.x1y1z1 = x1y1z1
    }

    public init(corner: Coordinate, oppositeCorner: Coordinate) {
        let x0 = corner.x
        let x1 = oppositeCorner.x
        let y0 = corner.y
        let y1 = oppositeCorner.y
        let z0 = corner.z
        let z1 = oppositeCorner.z
        self.init(x0: x0, x1: x1, y0: y0, y1: y1, z0: z0, z1: z1)
    }

    public init(x0: Float, x1: Float, y0: Float, y1: Float, z0: Float, z1: Float) {
        switch (x1 < x0, y1 < y0, z1 < z0) {
        case (true, true, true):
            self.x0y0z0 = Coordinate(x: x1, y: y1, z: z1)
            self.x1y1z1 = Coordinate(x: x0, y: y0, z: z0)
        case (true, true, false):
            self.x0y0z0 = Coordinate(x: x1, y: y1, z: z0)
            self.x1y1z1 = Coordinate(x: x0, y: y0, z: z1)
        case (true, false, true):
            self.x0y0z0 = Coordinate(x: x1, y: y0, z: z1)
            self.x1y1z1 = Coordinate(x: x0, y: y1, z: z0)
        case (true, false, false):
            self.x0y0z0 = Coordinate(x: x1, y: y0, z: z0)
            self.x1y1z1 = Coordinate(x: x0, y: y1, z: z1)
        case (false, true, true):
            self.x0y0z0 = Coordinate(x: x0, y: y1, z: z1)
            self.x1y1z1 = Coordinate(x: x1, y: y0, z: z0)
        case (false, true, false):
            self.x0y0z0 = Coordinate(x: x0, y: y1, z: z0)
            self.x1y1z1 = Coordinate(x: x1, y: y0, z: z1)
        case (false, false, true):
            self.x0y0z0 = Coordinate(x: x0, y: y0, z: z1)
            self.x1y1z1 = Coordinate(x: x1, y: y1, z: z0)
        case (false, false, false):
            self.x0y0z0 = Coordinate(x: x0, y: y0, z: z0)
            self.x1y1z1 = Coordinate(x: x1, y: y1, z: z1)

        }
    }

    public static let placeholder = Self(x0: 0, x1: 1, y0: 0, y1: 1, z0: 0, z1: 1)
}

public enum Octant: Int {
    case northWestForward = 0
    case northEastForward = 1
    case southWestForward = 2
    case southEastForward = 3
    case northWestBackward = 4
    case northEastBackward = 5
    case southWestBackward = 6
    case southEastBackward = 7

    var reversed: Self {
        return Octant(rawValue: 7 - self.rawValue)!
    }

    static let allValues: [Self] = [
        .northWestForward,
        .northEastForward,
        .southWestForward,
        .southEastForward,
        .northWestBackward,
        .northEastBackward,
        .southWestBackward,
        .southEastBackward,
    ]
}

public struct OctadChildren<T> {
    @usableFromInline let children: [T]

    @inlinable public subscript(at octant: Octant) -> T {
        get {
            return children[octant.rawValue]
        }
    }
}
