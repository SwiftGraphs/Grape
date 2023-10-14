//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/10/23.
//

//public protocol ComponentComparable {
//    @inlinable static func <(lhs: Self, rhs: Self) -> Bool
//    @inlinable static func <=(lhs: Self, rhs: Self) -> Bool
//    @inlinable static func >(lhs: Self, rhs: Self) -> Bool
//    @inlinable static func >=(lhs: Self, rhs: Self) -> Bool
//}

public struct NdBox<Coordinate> where Coordinate: VectorLike {
    public var p0: Coordinate
    public var p1: Coordinate
    
    
    @inlinable public init(p0:Coordinate, p1:Coordinate) {
        #if DEBUG
        assert(p0 != p1, "NdBox was initialized with 2 same anchor")
        #endif
        var p0 = p0
        var p1 = p1
        for i in p0.indices {
            if p1[i] < p0[i] {
                swap(&p0[i], &p1[i])
            }
        }
        self.p0 = p0
        self.p1 = p1
        // TODO: use Mask
    }
    
    @inlinable internal init(pMin:Coordinate, pMax:Coordinate) {
        #if DEBUG
        assert(pMin != pMax, "NdBox was initialized with 2 same anchor")
        #endif
        self.p0 = pMin
        self.p1 = pMax
    }
    
    @inlinable public init() {
        p0 = .zero
        p1 = .zero
    }
    
    public init(_ p0:Coordinate, _ p1: Coordinate) {
        self.init(p0:p0, p1:p1)
    }
    
}


extension NdBox {
    @inlinable var area: Coordinate.Scalar {
        var result: Coordinate.Scalar = 1
        let delta = p1 - p0
        for i in delta.indices {
            result *= delta[i]
        }
        return result
    }
    
    @inlinable var vec: Coordinate { p1 - p0 }
    
    @inlinable var center: Coordinate { (p1 + p0) / Coordinate.Scalar(2) }
    
    
    @inlinable func contains(_ point: Coordinate) -> Bool {
        for i in point.indices {
            if p0[i] > point[i] || point[i] >= p1[i] {
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


public protocol NdTreeDelegate {
    typealias NodeIndex = Int
    typealias BoxStorageIndex = Int
    associatedtype Coordinate: VectorLike
    @inlinable mutating func didAddNode(
        _ nodeIndex: NodeIndex,
        at position: Coordinate,
        in indexOfBoxStorage: BoxStorageIndex)
    @inlinable mutating func didRemoveNode(
        _ nodeIndex: NodeIndex,
        at position: Coordinate,
        in indexOfBoxStorage: BoxStorageIndex)
    init()
}


public final class CompactNdTree<C, TD> where C:VectorLike, TD: NdTreeDelegate, TD.Coordinate==C {
    
    public typealias Box = NdBox<C>
    
    public typealias NodeIndex = Int
    
    public typealias BoxStorageIndex = Int
    
    private var directionCount: Int
    
    fileprivate struct BoxStorage {
        // once initialized, should have C.entryCount elements
        var childrenBoxStorageIndices: [BoxStorageIndex]? = nil
        var nodeIndices: [NodeIndex]
        var box: Box // { didSet { center = box.center } }
        
        @inlinable init(
            box: Box,
            nodeIndices: [NodeIndex] = []
        ) {
            self.nodeIndices = nodeIndices
            self.box = box
//            self.center = box.center
            
        }
    }
    
    private var nodePositions: [C]
    private var boxStorages: [BoxStorage]
    
    private var clusterDistance: C.Scalar
    private var clusterDistanceSquared: C.Scalar
    
    
    public private(set) var delegate: TD
    
    public init(
        initialBox: Box,
        estimatedNodeCount: Int,
        clusterDistance: C.Scalar
    ) where TD: NdTreeDelegate {
        self.clusterDistance = clusterDistance
        self.clusterDistanceSquared = clusterDistance*clusterDistance
        self.directionCount = 1<<C.scalarCount
        self.boxStorages = [
            .init(box: initialBox)
        ]
        self.nodePositions = []
        self.boxStorages.reserveCapacity(4*estimatedNodeCount) // TODO: Probably too much? its ~29000 for 10000 random nodes
        self.nodePositions.reserveCapacity(estimatedNodeCount)
        
        self.delegate = TD()
    }
    
    
    
    
    public func add(
        _ nodeIndex: NodeIndex,
        at point: C
    ) {
        nodePositions.append(point)
        cover(point, boxStorageIndex: 0) // this can be moved to upper call
        add(nodeIndex: nodePositions.count - 1, at: point, boxStorageIndex: 0)
    }
    
    private func add(
        nodeIndex: NodeIndex,
        at point: C,
        boxStorageIndex: BoxStorageIndex
    ) {
        
        defer {
            delegate.didAddNode(nodeIndex, at: point, in: boxStorageIndex)
        }
        
        guard let childrenBoxStorageIndices = boxStorages[boxStorageIndex].childrenBoxStorageIndices else {
            if boxStorages[boxStorageIndex].nodeIndices.isEmpty
                || nodePositions[boxStorages[boxStorageIndex].nodeIndices.first!] == point
                || (nodePositions[boxStorages[boxStorageIndex].nodeIndices.first!]).distanceSquared(to: point) < self.clusterDistanceSquared {
                
                boxStorages[boxStorageIndex].nodeIndices.append(nodeIndex)
                
                return
            }
            else {
                
                var newChildren = Array(repeating: BoxStorage(box: Box()), count: directionCount)
                let _box = boxStorages[boxStorageIndex].box
                let p0 = _box.p0
                let p1 = _box.p1
                let pCenter = _box.center
                for j in newChildren.indices {
                    for i in 0..<C.scalarCount {
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
                
                let currentBoxStorageCount = self.boxStorages.count
                
                let _nodeIndices = boxStorages[boxStorageIndex].nodeIndices
                if !_nodeIndices.isEmpty {
                    // put the indices to new
                    let index = getIndexShiftInSubdivision(
                        nodePositions[_nodeIndices.first!],
                        relativeTo: pCenter
                    )
                    
                    newChildren[index].nodeIndices = _nodeIndices
                    
                    for ni in _nodeIndices {
                        delegate.didAddNode(ni, at: nodePositions[ni], in: currentBoxStorageCount+index)
                    }
                    
                    // this node will not have children any more
                    boxStorages[boxStorageIndex].nodeIndices=[]
                }
                self.boxStorages.append(contentsOf: newChildren)
                boxStorages[boxStorageIndex].childrenBoxStorageIndices = Array(currentBoxStorageCount..<currentBoxStorageCount+directionCount)
                
                let indexShiftForNewNode = getIndexShiftInSubdivision(
                    point,
                    relativeTo: pCenter
                )
                
                add(nodeIndex: nodeIndex, at: point, boxStorageIndex: //&boxStorages[
                    boxStorages[boxStorageIndex].childrenBoxStorageIndices![indexShiftForNewNode]
//                ]
                )
                
                return
            }
        }
        let indexShiftForNewNode = getIndexShiftInSubdivision(
            point,
            relativeTo: boxStorages[boxStorageIndex].box.center
        )
        
        #if DEBUG
        assert(boxStorages[childrenBoxStorageIndices[indexShiftForNewNode]].box.contains(point))
        #endif
        
        add(nodeIndex: nodeIndex, at: point, boxStorageIndex:
            childrenBoxStorageIndices[indexShiftForNewNode]
        )
        return
    }
    

    
    private func cover(_ point:C, boxStorageIndex: BoxStorageIndex) {
        
        if boxStorages[boxStorageIndex].box.contains(point) { return }
        repeat {
            let _box = boxStorages[boxStorageIndex].box
            let indexShift = getIndexShiftInSubdivision(point, relativeTo: _box.p0)
            
            let nailedDirectionIndexShift = (directionCount-1)-indexShift
            
            let nailedCorner = _box.getCorner(of: nailedDirectionIndexShift)
            let expandedCorner = _box.getCorner(of: indexShift) * 2 - nailedCorner
            
            let newRootBox = Box(p0: nailedCorner, p1: expandedCorner)
            
            
            let copyOfCurrentBoxStorage = boxStorages[boxStorageIndex]
            
            boxStorages[boxStorageIndex].box = newRootBox
            
            #if DEBUG
            assert(copyOfCurrentBoxStorage.box.p0 != boxStorages[boxStorageIndex].box.p0 || copyOfCurrentBoxStorage.box.p1 != boxStorages[boxStorageIndex].box.p1)
            #endif
            
            appendDividedChildren(boxStorageIndex: boxStorageIndex)
            boxStorages[
                boxStorages[boxStorageIndex].childrenBoxStorageIndices![
                    //indexShift
                    getIndexShiftInSubdivision(point, relativeTo: expandedCorner) 
                    // <- to the center of the new box
                ]
            ] = copyOfCurrentBoxStorage
            
            
        } while !boxStorages[boxStorageIndex].box.contains(point)
    }
    
    
    private func getIndexShiftInSubdivision(_ point: C, relativeTo originalPoint: C) -> Int {
        var index = 0
        for i in 0..<C.scalarCount {
            if point[i] >= originalPoint[i] { // isOnHigherRange in this dimension
                index |= (1<<i)
            }
        }
        return index
    }
    
    
    private func appendDividedChildren(boxStorageIndex: BoxStorageIndex) {
        var newChildren = Array(repeating: BoxStorage(box: Box()), count: directionCount)
        let box = boxStorages[boxStorageIndex].box
        let p0 = box.p0
        let p1 = box.p1
        let pCenter = box.center
        
        for j in newChildren.indices {
            for i in 0..<C.scalarCount {
                let isOnTheHigherRange = (j >> i) & 0b1
                
                // TODO: use simd mask
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
        
        
//        defer {
//            self.boxStorages.append(contentsOf: newChildren)
//        }
        
        let _boxStorage = boxStorages[boxStorageIndex]
        if !_boxStorage.nodeIndices.isEmpty {
            // put the indices to new
            let point = nodePositions[_boxStorage.nodeIndices.first!]
            
            let index = getIndexShiftInSubdivision(point, relativeTo: pCenter)
            
            newChildren[index].nodeIndices = _boxStorage.nodeIndices
            
            // this node will not have children any more
            boxStorages[boxStorageIndex].nodeIndices=[]
        }
        
        let currentBoxStorageCount = boxStorages.count
        
        self.boxStorages.append(contentsOf: newChildren)
        let newIndices = Array(currentBoxStorageCount ..< currentBoxStorageCount+directionCount)
        boxStorages[boxStorageIndex].childrenBoxStorageIndices = newIndices
    }
}


public extension CompactNdTree {
    var rootBox: Box { boxStorages[0].box }
}


extension NdBox: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "[\(p0), \(p1)]"
    }
}
