//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/14/23.
//




public protocol NDTreeDelegate {
    associatedtype Node
    associatedtype V: VectorLike
    mutating func didAddNode(_ node: Node, at position: V)
    mutating func didRemoveNode(_ node: Node, at position: V)
    func copy() -> Self
    func spawn() -> Self
}

public final class NDTree<V, D> where V: VectorLike, D: NDTreeDelegate, D.Node == Int, D.V == V {
    
    public typealias NodeIndex = Int
    
    public typealias Direction = Int
    
    public typealias Box = NDBox<V>
    
    public private(set) var box: Box
    
    public private(set) var children: [NDTree<V, D>]?
    
    public private(set) var nodePosition: V?
    public private(set) var nodeIndices: [NodeIndex]
    
    public let clusterDistance: V.Scalar
    private let clusterDistanceSquared: V.Scalar
    
    private let directionCount: Int
    
    public private(set) var delegate: D
    
    init(
        box: Box,
        clusterDistance: V.Scalar,
        parentDelegate: inout D
    ) {
        self.box = box
        self.clusterDistance = clusterDistance
        self.clusterDistanceSquared = clusterDistance * clusterDistance
        self.directionCount = 1 << V.scalarCount
        self.nodeIndices = []
        
        self.delegate = parentDelegate.spawn()
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
            if nodePosition == nil || nodePosition == point || nodePosition!.distanceSquared(to: point) < clusterDistanceSquared {
                nodeIndices.append(nodeIndex)
                return
            }
            else {
                let spawned = Self.spawnChildren(
                    box,
                    directionCount,
                    clusterDistance,
                    &delegate
                )
                
                if let nodePosition {
                    let direction = getIndexInChildren(nodePosition, relativeTo: box.center)
                    spawned[direction].nodeIndices = self.nodeIndices
                    spawned[direction].nodePosition = self.nodePosition
                    self.delegate = self.delegate.copy()
                    
                    for ni in nodeIndices {
                        delegate.didAddNode(ni, at: nodePosition)
                    }
                    
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
        let nailedDirection = (directionCount - 1) - direction
        let nailedCorner = box.getCorner(of: nailedDirection)
        let expandedCorner = box.getCorner(of: direction) * 2 - nailedCorner
        
        let newRootBox = Box(nailedCorner, expandedCorner)
        
        let copiedCurrentNode = shallowCopy()
        var spawned = Self.spawnChildren(
            box,
            directionCount,
            clusterDistance,
            &delegate
        )
        
        spawned[nailedDirection] = copiedCurrentNode
        
        self.box = newRootBox
        self.children = spawned
        self.nodeIndices = []
        self.delegate = delegate.copy()

    }
    
    private static func spawnChildren(
        _ _box: Box,
        _ _directionCount: Int,
        _ _clusterDistance: V.Scalar,
        _ _delegate: inout D
    ) -> [NDTree<V, D>] {
        var spawned = Array(repeating: _box, count: _directionCount)
        var center = _box.center
        
        for j in spawned.indices {
            for i in 0..<V.scalarCount {
                let isOnTheHigherRange = (j >> i) & 0b1

                // TODO: use simd mask
                if isOnTheHigherRange != 0 {
                    spawned[j].p0[i] = center[i]
                } else {
                    spawned[j].p1[i] = center[i]
                }
            }
        }
        return spawned.map { b in
            NDTree(box: b, clusterDistance: _clusterDistance, parentDelegate: &_delegate)
        }
    }
    
    /// Copy object while holding the same reference to children
    private func shallowCopy() -> NDTree<V, D> {
        let copy = NDTree(box: box, clusterDistance: clusterDistance, parentDelegate: &delegate)
        
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









extension NDTree {
    @inlinable public var extent: Box { box }
}
