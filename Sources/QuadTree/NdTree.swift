//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/10/23.
//

import Foundation

public protocol ComponentComparable {
    @inlinable static func <(lhs: Self, rhs: Self) -> Bool
    @inlinable static func <=(lhs: Self, rhs: Self) -> Bool
    @inlinable static func >(lhs: Self, rhs: Self) -> Bool
    @inlinable static func >=(lhs: Self, rhs: Self) -> Bool
}

public struct NdBox<Coordinate> where Coordinate: SIMD<Double>, Coordinate: ComponentComparable {
    public var p0: Coordinate
    public var p1: Coordinate
    
    @inlinable public init(p0:Coordinate, p1:Coordinate) {
        var p0 = p0
        var p1 = p1
        for i in p0.indices {
            if p1[i] < p0[i] {
                swap(&p0[i], &p1[i])
            }
        }
        self.p0 = p0
        self.p1 = p1
    }
    
    public static var unit: Self { .init(p0: .zero, p1: .one) }
}

extension NdBox {
    var area: Double {
        var result: Double = 1
        let delta = p1 - p0
        for i in delta.indices {
            result *= delta[i]
        }
        return result
    }
    
    var vec: Coordinate { p1 - p0 }
    
    var center: Coordinate { (p1+p0) / 2 }
    
    @inlinable public func getCorner<Direction>(
        of direction: Direction
    ) -> Coordinate where Direction: NdDirection, Direction.Coordinate == Coordinate {
        var result = Coordinate()
        var value = direction.rawValue
        
        // starting from the last element
        for i in (0..<Coordinate.scalarCount).reversed() {
            result[i] = value % 2 == 1 ? p1[i] : p0[i]
            value /= 2
        }
        return result
    }
    
    @inlinable func contains(_ point: Coordinate) -> Bool {
        return (p0 <= point) && (point < p1)
    }
}

/// Reversed bit representation for nth dimension
/// e.g.    for 3d:         0b001 => (x:0, y:0, z:1)
public protocol NdDirection: RawRepresentable {
    associatedtype Coordinate: SIMD<Double>
    var rawValue: Int { get }
    var reversed: Self { get }
    static var entryCount: Int { get }
}

//public extension SIMD<Double> {
//    @inlinable func direction<Direction>(originalPoint point: Self) -> Direction where Direction: NdDirection, Direction.Coordinate == Self {
//        
//    }
//}

struct OctDirection: NdDirection {
    typealias Coordinate = SIMD3<Double>
    let rawValue: Int
    var reversed: OctDirection {
        return OctDirection(rawValue: 7-rawValue)
    }
    static let entryCount: Int = 8
}

public struct NdChildren<T, Coordinate> where Coordinate: SIMD<Double> {
    @usableFromInline internal let children: [T]
    
    @inlinable public subscript<Direction>(
        at direction: Direction
    ) -> T where Direction: NdDirection, Direction.Coordinate == Coordinate {
        return children[direction.rawValue]
    }
}


public protocol TreeNodeDelegate {
    associatedtype Node
    associatedtype Index: Hashable
    mutating func didAddNode(_ node: Index, at position: Vector2f)
    mutating func didRemoveNode(_ node: Index, at position: Vector2f)
    func copy() -> Self
    func createNew() -> Self
}


public final class NdTree<C, TD> where C:SIMD<Double>, C:ComponentComparable, TD: TreeNodeDelegate {
    
    public typealias Box = NdBox<C>
    public typealias Children = NdChildren<NdTree<C, TD>, C>
    public typealias Index = Int
    public typealias Direction = Int
    
    public private(set) var box: NdBox<C>
    
    public var nodes: [Index] = []
    public private(set) var children: Children?
    public let clusterDistance: Double
    public var delegate: TD
    
    init(
        box: Box,
        clusterDistance: Double,
        rootNodeDelegate: TD
    ) {
        self.box = box
        self.clusterDistance = clusterDistance
        self.delegate = rootNodeDelegate.createNew()
    }
    
    public func add(_ nodeIndex: Index, at point: C) {
        
    }
    
    
    private func cover(_ point: C) {
        if box.contains(point) { return }
        
        repeat {
            
//            let direction: Direction =
//
//            expand(towards: direction)

        } while !box.contains(point)
    }
    
    private func expand(towards direction: Direction) {
        
    }
}
