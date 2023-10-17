//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/14/23.
//

public protocol NDTreeDelegate {
    associatedtype NodeID: Hashable
    associatedtype V: VectorLike
    mutating func didAddNode(_ node: NodeID, at position: V)
    mutating func didRemoveNode(_ node: NodeID, at position: V)
    func copy() -> Self
    func spawn() -> Self
}

public final class NDTree<V, D> where V: VectorLike, D: NDTreeDelegate, D.V == V {
    
    public typealias NodeIndex = D.NodeID
    
    public typealias Direction = Int
    
    public typealias Box = NDBox<V>
    
    public private(set) var box: Box
    
    public private(set) var children: [NDTree<V, D>]?
    
    public private(set) var nodePosition: V?
    public private(set) var nodeIndices: [NodeIndex]
    
    public let clusterDistance: V.Scalar
    private let clusterDistanceSquared: V.Scalar
    
    
    public private(set) var delegate: D
    
    private init(
        box: Box,
        clusterDistance: V.Scalar,
        parentDelegate: D
    ) {
        self.box = box
        self.clusterDistance = clusterDistance
        self.clusterDistanceSquared = clusterDistance * clusterDistance
        self.nodeIndices = []
        self.delegate = parentDelegate.spawn()
    }

    
    public init(
        box: Box,
        clusterDistance: V.Scalar,
        buildRootDelegate: () -> D
    ) {
        self.box = box
        self.clusterDistance = clusterDistance
        self.clusterDistanceSquared = clusterDistance * clusterDistance
        self.nodeIndices = []
        self.delegate = buildRootDelegate()
    }
    
    public convenience init(
        covering nodes: [NodeIndex: V],
        clusterDistance: V.Scalar,
        buildRootDelegate: () -> D
    ) {
        let coveringBox = Box.cover(of: Array(nodes.values))
        self.init(box: coveringBox, 
                  clusterDistance: clusterDistance,
                  buildRootDelegate: buildRootDelegate)
        for (i, p) in nodes {
            add(i, at: p)
        }
    }
    
    
    public func add(_ nodeIndex: NodeIndex, at point: V) {
        cover(point)
        
        addWithoutCover(nodeIndex, at: point)
        
    }
    
    private func addWithoutCover(_ nodeIndex: NodeIndex, at point: V) {
        defer {
            delegate.didAddNode(nodeIndex, at: point)
        }
        
        guard let children = self.children else {
            if nodePosition == nil {
                nodeIndices.append(nodeIndex)
                nodePosition = point
                return
            }
            else if nodePosition == point || nodePosition!.distanceSquared(to: point) < clusterDistanceSquared {
                nodeIndices.append(nodeIndex)
                return
            }
            else {
                
                let spawned = Self.spawnChildren(
                    box,
//                    V.directionCount,
                    clusterDistance,
                    /*&*/delegate
                )
                
                if let nodePosition {
                    let direction = getIndexInChildren(nodePosition, relativeTo: box.center)
                    spawned[direction].nodeIndices = self.nodeIndices
                    spawned[direction].nodePosition = self.nodePosition
                    spawned[direction].delegate = self.delegate.copy()
//                    self.delegate = self.delegate.copy()
                    
                    
                    
//                    for ni in nodeIndices {
//                        delegate.didAddNode(ni, at: nodePosition)
//                    }
                    
                    self.nodeIndices = []
                    self.nodePosition = nil
                }
                
                let directionOfNewNode = getIndexInChildren(point, relativeTo: box.center)
                spawned[directionOfNewNode].addWithoutCover(nodeIndex, at: point)
                
                self.children = spawned
                return

            }
        }
        
        let directionOfNewNode = getIndexInChildren(point, relativeTo: box.center)
        children[directionOfNewNode].addWithoutCover(nodeIndex, at: point)
        
        return
    }
    
    private func cover(_ point: V) {
        if box.contains(point) { return }
        
        repeat {
            let direction = getIndexInChildren(point, relativeTo: box.p0)
            expand(towards: direction)
        } while !box.contains(point)
    }
    
    
    private func expand(towards direction: Direction) {
        let nailedDirection = (V.directionCount - 1) - direction
        let nailedCorner = box.getCorner(of: nailedDirection)
        
        let _corner = box.getCorner(of: direction)
        let expandedCorner = (_corner+_corner) - nailedCorner
        
        let newRootBox = Box(nailedCorner, expandedCorner)
        
        let copiedCurrentNode = shallowCopy()
        var spawned = Self.spawnChildren(
            newRootBox,
//            V.directionCount,
            clusterDistance,
            /*&*/delegate
        )
        
        spawned[nailedDirection] = copiedCurrentNode
        
        self.box = newRootBox
        self.children = spawned
        self.nodeIndices = []
        self.delegate = delegate.copy()

    }
    
    private static func spawnChildren(
        _ _box: Box,
        _ _clusterDistance: V.Scalar,
        _ _delegate: D
    ) -> [NDTree<V, D>] {
        
        
//        var spawned = Array(repeating: _box, count: _directionCount)
//        
//        
//        
//        let center = _box.center
//        
//        for j in spawned.indices {
//            for i in 0..<V.scalarCount {
//                let isOnTheHigherRange = (j >> i) & 0b1
//
//                // TODO: use simd mask
//                if isOnTheHigherRange != 0 {
//                    spawned[j].p0[i] = center[i]
//                } else {
//                    spawned[j].p1[i] = center[i]
//                }
//            }
//        }
//        var result = [NDTree<V, D>]()
//        result.reserveCapacity(_directionCount)
//        for b in spawned {
//            result.append(NDTree(box: b, clusterDistance: _clusterDistance, parentDelegate: /*&*/_delegate))
//        }
        
        var result = [NDTree<V, D>]()
        result.reserveCapacity(V.directionCount)
        let center = _box.center
        
        for j in 0..<V.directionCount {
                    var __box = _box
                    for i in 0..<V.scalarCount {
                        let isOnTheHigherRange = (j >> i) & 0b1
        
                        // TODO: use simd mask
                        if isOnTheHigherRange != 0 {
                            __box.p0[i] = center[i]
                        } else {
                            __box.p1[i] = center[i]
                        }
                    }
            result.append(NDTree(box: __box, clusterDistance: _clusterDistance, parentDelegate: /*&*/_delegate))
        }
        
        return result
    }
    
    /// Copy object while holding the same reference to children
    private func shallowCopy() -> NDTree<V, D> {
        let copy = NDTree(box: box, clusterDistance: clusterDistance, parentDelegate: /*&*/delegate)
        
        copy.nodeIndices = nodeIndices
        copy.nodePosition = nodePosition
        copy.children = children
        copy.delegate = delegate
        
        return copy
    }
    
    
    private func getIndexInChildren(_ point: V, relativeTo originalPoint: V) -> Int {
        var index = 0
        for i in 0..<V.scalarCount {
            if point[i] >= originalPoint[i] {  // isOnHigherRange in this dimension
                index |= (1 << i)
            }
        }
        return index
    }

}

extension NDTree where D.NodeID == Int {
    public convenience init(
        covering points: [V],
        clusterDistance: V.Scalar,
        buildRootDelegate: () -> D
    ) {
        let coveringBox = Box.cover(of: points)
        self.init(box: coveringBox, clusterDistance: clusterDistance, buildRootDelegate: buildRootDelegate)
        for i in points.indices {
            add(i, at: points[i])
        }
    }
    
    public convenience init<T>(
        covering points: [T],
        keyPath: KeyPath<T, V>,
        clusterDistance: V.Scalar,
        buildRootDelegate: () -> D
    ) {
        let coveringBox = Box.cover(of: points, keyPath: keyPath)
        self.init(box: coveringBox, clusterDistance: clusterDistance, buildRootDelegate: buildRootDelegate)
        for i in points.indices {
            add(i, at: points[i][keyPath: keyPath])
        }
    }
}



extension NDTree {
    @inlinable public var extent: Box { box }
    
    @inlinable public var isLeaf: Bool { children == nil }
    @inlinable public var isInternalNode: Bool { children != nil }
    
    @inlinable public var isFilledLeaf: Bool { nodePosition != nil }
    @inlinable public var isEmptyLeaf: Bool { nodePosition == nil }

}
