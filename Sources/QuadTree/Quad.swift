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


public typealias Vector2f = simd_float2

extension Vector2f: AdditiveArithmetic {
    
    @inlinable public func lengthSquared() -> Float {
        return x*x + y*y
    }
    
    @inlinable public func length() -> Float {
        return (x*x + y*y).squareRoot()
    }
    
    @inlinable public func squaredDistanceTo(_ point: Self) -> Float {
        return (self - point).lengthSquared()
    }
    
    @inlinable public func distanceTo(_ point: Self) -> Float {
        return (self - point).length()
    }
}


public struct Quad {
    private var x0y0: simd_float2
    private var x1y1: simd_float2
    
    public var x0: Float {
        get {
            x0y0.x
        }
        set {
            x0y0.x = newValue
        }
    }
    
    public var x1: Float {
        get {
            x1y1.x
        }
        set {
            x1y1.x = newValue
        }
    }

    public var y0: Float {
        get {
            x0y0.y
        }
        set {
            x0y0.y = newValue
        }
    }
    
    public var y1: Float {
        get {
            x1y1.y
        }
        set {
            x1y1.y = newValue
        }
    }

    private init(x0y0: simd_float2, x1y1: simd_float2) {
        self.x0y0 = x0y0
        self.x1y1 = x1y1
    }

    public init(corner: Vector2f, oppositeCorner: Vector2f) {
        let x0 = corner.x
        let x1 = oppositeCorner.x
        let y0 = corner.y
        let y1 = oppositeCorner.y
        self.init(x0: x0, x1: x1, y0: y0, y1: y1)
    }

    public init(x0: Float, x1: Float, y0: Float, y1: Float) {
        switch(x1<x0, y1<y0) {
        case (true, true):
            self.x0y0 = simd_float2(x: x1, y: y1)
            self.x1y1 = simd_float2(x: x0, y: y0)
        case (true, false):
            self.x0y0 = simd_float2(x: x1, y: y0)
            self.x1y1 = simd_float2(x: x0, y: y1)
        case (false, true):
            self.x0y0 = simd_float2(x: x0, y: y1)
            self.x1y1 = simd_float2(x: x1, y: y0)
        case (false, false):
            self.x0y0 = simd_float2(x: x0, y: y0)
            self.x1y1 = simd_float2(x: x1, y: y1)
        }
    }
    
    public static let placeholder = Self(x0: 0, x1: 0, y0: 1, y1: 1)
}

public enum Quadrant {
    case northWest
    case northEast
    case southWest
    case southEast

    var reversed: Self {
        switch self {
        case .northWest:
            return .southEast
        case .northEast:
            return .southWest
        case .southWest:
            return .northEast
        case .southEast:
            return .northWest
        }
    }

    static let allValues: [Self] = [.northWest, .northEast, .southWest, .southEast]
}

public struct QuadChildren<T> {
    let northWest: T
    let northEast: T
    let southWest: T
    let southEast: T

    public subscript(at quadrant: Quadrant) -> T {
        get {
            switch quadrant {
            case .northWest:
                return northWest
            case .northEast:
                return northEast
            case .southWest:
                return southWest
            case .southEast:
                return southEast
            }
        }
    }
}


public extension Quad {
    
    typealias Children = QuadChildren<Self>

    var size: Vector2f {
        return x1y1 - x0y0
    }
    
    var area: Float {
        return size.x * size.y
    }

    var center: Vector2f {
        return (x0y0 + x1y1) / 2
    }

    func getCorner(of quadrant: Quadrant) -> Vector2f {
        switch quadrant {
        case .northWest:
            return x0y0
        case .northEast:
            return Vector2f(x: x1, y: y0)
        case .southWest:
            return Vector2f(x: x0, y: y1)
        case .southEast:
            return x1y1
        }
    }
    
    func divide() -> Children {
        return QuadChildren(
            northWest: .init(x0: x0, x1: center.x, y0: y0, y1: center.y),
            northEast: .init(x0: center.x, x1: x1, y0: y0, y1: center.y),
            southWest: .init(x0: x0, x1: center.x, y0: center.y, y1: y1),
            southEast: .init(x0: center.x, x1: x1, y0: center.y, y1: y1)
        )
    }
    
    @inlinable func contains(_ point: Vector2f) -> Bool {
        return x0 <= point.x && x1 > point.x && y0 <= point.y && y1 > point.y
    }
    
    /**
     * (0, 0)
     *           |    point: .northEast
     *           |
     *    ---- CENTER ---- 
     *           |
     *           |
     *
     */
    @inlinable func quadrantOf(_ point: Vector2f) -> Quadrant{
        switch (point.y < center.y, point.x < center.x) {
        case (true, true):
            return .northWest
        case (true, false):
            return .northEast
        case (false, true):
            return .southWest
        case (false, false):
            return .southEast
        }
    }
    
    @inlinable func quadrantOfOrNilIfNotContained(_ point: Vector2f) -> Quadrant? {
        guard contains(point) else { return nil }
        return quadrantOf(point)
    }
    
    @inlinable func intersect(with quad: Quad) -> Quad? {
        let x0 = max(self.x0, quad.x0)
        let x1 = min(self.x1, quad.x1)
        let y0 = max(self.y0, quad.y0)
        let y1 = min(self.y1, quad.y1)
        if x0 < x1 && y0 < y1 {
            return Quad(x0: x0, x1: x1, y0: y0, y1: y1)
        }
        return nil
    }

    static func cover(_ point: Vector2f) -> Quad {
        let x0 = floor(point.x)
        var x1 = ceil(point.x)
        let y0 = floor(point.y)
        var y1 = ceil(point.y)
        if y1 == y0 || y1 == point.y {
            y1 += 1
        }
        if x1 == x0 || x1 == point.x {
            x1 += 1
        }
        return Quad(x0: x0, x1: x1, y0: y0, y1: y1)
    }
}


extension Quad: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "[x0:\(x0), x1:\(x1), y0:\(y0), y1:\(y1)]"
    }
}
