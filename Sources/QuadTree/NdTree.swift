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

public struct NdBox<Coordinate> where Coordinate: SIMD<Double> {
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
    
    var center: Coordinate { (p1 + p0) / 2 }
    
    
    @inlinable func contains(_ point: Coordinate) -> Bool {
        for i in point.indices {
            if p0[i] > point[i] {
                return false
            }
            else if point[i] >= p1[i] {
                return false
            }
        }
        return true
//        return (p0 <= point) && (point < p1)
    }
}


extension NdBox {
    @inlinable func getCorner(of direction: Int) -> Coordinate {
        var corner = Coordinate.zero
        for i in 0..<Coordinate.scalarCount {
            corner[i] = ((direction>>i) & 0b1)==1 ? p1[i] : p0[i]
        }
        return corner
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


public final class CompactNdTree<C, TD> where C:SIMD<Double>, C:VectorLike, C.Scalar==Double,TD: TreeNodeDelegate {
    
    public typealias Box = NdBox<C>
    
    public typealias NodeIndex = Int
    
    
    
    
    
    public typealias BoxStorageIndex = Int
    
    
    private var directionCount: Int
    
    private struct BoxStorage {
        // once initialized, should have C.entryCount elements
        var childrenBoxStorageIndices: [BoxStorageIndex]? = nil
        var nodeIndices: [NodeIndex]
        var box: Box { didSet { center = box.center } }
        var center: C
        
        @inlinable init(
            box: Box,
            nodeIndices: [NodeIndex] = []
        ) {
            self.nodeIndices = nodeIndices
            self.box = box
            self.center = box.center
            
        }
        
    }
    
    private var nodePositions: [C]
    private var boxStorages: [BoxStorage]
    
    private var clusterDistance: Double
    private var clusterDistanceSquared: Double
    
    
//    private var startOfChildrenIndices: [Int]
    
    init(
        estimatedNodeCount: Int,
        clusterDistance: Double = 1e-5
    ) {
        self.clusterDistance = clusterDistance
        self.clusterDistanceSquared = clusterDistance*clusterDistance
        
        
        self.boxStorages = []
        self.nodePositions = []
        
        self.boxStorages.reserveCapacity(4*estimatedNodeCount)
        self.nodePositions.reserveCapacity(estimatedNodeCount)
        
        self.directionCount = 1<<C.scalarCount
    }
    
    
    private func add(
        nodeIndex: NodeIndex,
        at point: C,
        boxStorage: inout BoxStorage
    ) {
        cover(point, boxStorage: &boxStorage)
        
        defer {
            // TODO: Perform delegate actions
        }
        
        guard let childrenBoxStorageIndices = boxStorage.childrenBoxStorageIndices else {
            if boxStorage.nodeIndices.isEmpty
                || nodePositions[boxStorage.nodeIndices.first!] == point
                || (nodePositions[boxStorage.nodeIndices.first!]).distanceSquared(to: point) < self.clusterDistanceSquared {
                
                boxStorage.nodeIndices.append(nodeIndex)
                
                return
            }
            else {
                
                var newChildren = Array(repeating: BoxStorage(box: Box(p0: .zero, p1: .zero)), count: directionCount)
                let p0 = boxStorage.box.p0
                let p1 = boxStorage.box.p1
                let pCenter = boxStorage.box.center
                for i in 0..<C.scalarCount {
                    for j in newChildren.indices {
                        let isOnTheHigherRange = (j >> i) & 0b1
                        if isOnTheHigherRange != 0 {
                            newChildren[j].box.p0[i] = pCenter[i]
                            newChildren[j].box.p1[i] = p1[i]
                        }
                        else {
                            newChildren[j].box.p0[i] = p0[i]
                            newChildren[j].box.p1[i] = pCenter[i]
                        }
                    }
                }
                
                defer { self.boxStorages.append(contentsOf: newChildren) }
                
                if !boxStorage.nodeIndices.isEmpty {
                    // put the indices to new
                    let index = getIndexShiftInSubdivision(
                        point: nodePositions[boxStorage.nodeIndices.first!],
                        pCenter: pCenter
                    )
                    
                    newChildren[index].nodeIndices = boxStorage.nodeIndices
                    
                    // this node will not have children any more
                    boxStorage.nodeIndices=[]
                }
                boxStorage.childrenBoxStorageIndices=Array(boxStorages.count..<boxStorages.count+directionCount)
                
                let indexShiftForNewNode = getIndexShiftInSubdivision(
                    point: point,
                    pCenter: pCenter
                )
                
                add(nodeIndex: nodeIndex, at: point, boxStorage: &boxStorages[
                    boxStorage.childrenBoxStorageIndices![indexShiftForNewNode]
                ])
                
                return
            }
        }
        let indexShiftForNewNode = getIndexShiftInSubdivision(
            point: point,
            pCenter: boxStorage.center
        )
        
        add(nodeIndex: nodeIndex, at: point, boxStorage: &boxStorages[
            boxStorage.childrenBoxStorageIndices![indexShiftForNewNode]
        ])
        
        return
    }
    

    
    private func cover(_ point:C, boxStorage: inout BoxStorage) {
        if boxStorage.box.contains(point) { return }
        repeat {
            let indexShift = getIndexShiftInSubdivision(point: point, pCenter: boxStorage.box.p0)
            
            let nailedDirectionIndexShift = (directionCount-1)-indexShift
            
            let nailedCorner = boxStorage.box.getCorner(of: nailedDirectionIndexShift)
            let expandedCorner = boxStorage.box.getCorner(of: indexShift) * 2 - nailedCorner
            
            let newRootBox = Box(p0: nailedCorner, p1: expandedCorner)
            
            
            let copyOfCurrentBoxStorage = boxStorage
            
            boxStorage.box = newRootBox
            
            #if DEBUG
            assert(copyOfCurrentBoxStorage.box.p0 != boxStorage.box.p0 || copyOfCurrentBoxStorage.box.p1 != boxStorage.box.p1)
            #endif
            
            appendDividedChildren(boxStorage: &boxStorage)
            boxStorages[boxStorage.childrenBoxStorageIndices![indexShift]] = copyOfCurrentBoxStorage
            
            
        } while !boxStorage.box.contains(point)
    }
    
    
    private func getIndexShiftInSubdivision(point: C, pCenter: C) -> Int {
        var index = 0
        for i in 0..<C.scalarCount {
            if point[i] >= pCenter[i] { // isOnHigherRange in this dimension
                index |= (1<<i)
            }
        }
        return index
    }
    
    
    private func appendDividedChildren(boxStorage: inout BoxStorage) {
        var newChildren = Array(repeating: BoxStorage(box: Box(p0: .zero, p1: .zero)), count: directionCount)
        let p0 = boxStorage.box.p0
        let p1 = boxStorage.box.p1
        let pCenter = boxStorage.box.center
        for i in 0..<C.scalarCount {
            for j in newChildren.indices {
                let isOnTheHigherRange = (j >> i) & 0b1
                if isOnTheHigherRange != 0 {
                    newChildren[j].box.p0[i] = pCenter[i]
                    newChildren[j].box.p1[i] = p1[i]
                }
                else {
                    newChildren[j].box.p0[i] = p0[i]
                    newChildren[j].box.p1[i] = pCenter[i]
                }
            }
        }
        
        defer { self.boxStorages.append(contentsOf: newChildren) }
        
        if !boxStorage.nodeIndices.isEmpty {
            // put the indices to new
            let point = nodePositions[boxStorage.nodeIndices.first!]
            
            let index = getIndexShiftInSubdivision(point: point, pCenter: pCenter)
            
            newChildren[index].nodeIndices = boxStorage.nodeIndices
            
            // this node will not have children any more
            boxStorage.nodeIndices=[]
        }
        boxStorage.childrenBoxStorageIndices=Array(boxStorages.count..<boxStorages.count+directionCount)
    }
    
    
}
