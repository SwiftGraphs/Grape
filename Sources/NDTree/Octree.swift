//
//  Octree.swift
//
//
//  Created by li3zhen1 on 10/22/23.
//

import simd

/// The data structure carried by a node of NDTree
/// It receives notifications when a node is added or removed on a node, regardless of whether the node is internal or leaf.
/// It is designed to calculate properties like a box's center of mass.
public protocol OctreeDelegate {
    associatedtype NodeID: Hashable
    typealias V = simd_float3

    /// Called when a node is added on a node, regardless of whether the node is internal or leaf.
    /// If you add `n` points to the root, this method will be called `n` times in the root delegate, 
    /// although it is probably not containing points now.
    /// - Parameters:
    ///   - node: The nodeID of the node that is added.
    ///   - position: The position of the node that is added.
    mutating func didAddNode(_ node: NodeID, at position: V)

    /// Called when a node is removed on a node, regardless of whether the node is internal or leaf.
    mutating func didRemoveNode(_ node: NodeID, at position: V)

    /// Copy object. This method is called when the root box is not large enough to cover the new nodes.
    /// The method
    func copy() -> Self

    /// Create new object with properties set to initial value as if the box is empty.
    /// However, you can still carry something like a closure to get information from outside.
    /// This method is called when a leaf box is splited due to the insertion of a new node in this box.
    func spawn() -> Self
}

/// A node in NDTree
/// - Note: `NDTree` is a generic type that can be used in any dimension.
///        `NDTree` is a reference type.
public final class Octree<D> where D: OctreeDelegate {

    public typealias V = simd_float3

    public typealias NodeIndex = D.NodeID

    public typealias Direction = Int

    public typealias Box = NDBox<V>

    public private(set) var box: Box

    public private(set) var children: [Octree<D>]?

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
        self.init(
            box: coveringBox,
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
            } else if nodePosition == point
                || simd_length_squared(nodePosition! - point) < clusterDistanceSquared
            {
                nodeIndices.append(nodeIndex)
                return
            } else {

                let spawned = Self.spawnChildren(
                    box,
                    //                    Self.directionCount,
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

    /// Expand the current node multiple times by calling `expand(towards:)`, until the point is covered.
    /// - Parameter point: The point to be covered.
    private func cover(_ point: V) {
        if box.contains(point) { return }

        repeat {
            let direction = getIndexInChildren(point, relativeTo: box.p0)
            expand(towards: direction)
        } while !box.contains(point)
    }

    /// Expand the current node towards a direction. The expansion
    /// will double the size on each dimension. Then the data in delegate will be copied to the new children.
    /// - Parameter direction: An Integer between 0 and `directionCount - 1`, where `directionCount` equals to 2^(dimension of the vector).
    private func expand(towards direction: Direction) {
        let nailedDirection = (Self.directionCount - 1) - direction
        let nailedCorner = box.getCorner(of: nailedDirection)

        let _corner = box.getCorner(of: direction)
        let expandedCorner = (_corner + _corner) - nailedCorner

        let newRootBox = Box(nailedCorner, expandedCorner)

        let copiedCurrentNode = shallowCopy()
        var spawned = Self.spawnChildren(
            newRootBox,
            //            Self.directionCount,
            clusterDistance,
            /*&*/delegate
        )

        spawned[nailedDirection] = copiedCurrentNode

        self.box = newRootBox
        self.children = spawned
        self.nodeIndices = []
        self.delegate = delegate.copy()

    }

    /// The children count of a node in NDTree.
    /// Should be equal to the 2^(dimension of the vector).
    /// For example, a 2D vector should have 4 children, a 3D vector should have 8 children.
    /// This property is a getter property but it is probably be inlined.
    @inlinable static var directionCount: Int { 1 << V.scalarCount }

    private static func spawnChildren(
        _ _box: Box,
        _ _clusterDistance: V.Scalar,
        _ _delegate: D
    ) -> [Octree<D>] {

        var result = [Octree<D>]()
        result.reserveCapacity(Self.directionCount)
        let center = _box.center

        for j in 0..<Self.directionCount {
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
            result.append(
                Self(
                    box: __box, clusterDistance: _clusterDistance, parentDelegate: /*&*/ _delegate)
            )
        }

        return result
    }

    /// Copy object while holding the same reference to children.
    /// Consider this function something you would do when working with linked list.
    private func shallowCopy() -> Self {
        let copy = Self(
            box: box, clusterDistance: clusterDistance, parentDelegate: /*&*/ delegate)

        copy.nodeIndices = nodeIndices
        copy.nodePosition = nodePosition
        copy.children = children
        copy.delegate = delegate

        return copy
    }

    /// Get the index of the child that contains the point.
    /// **Complexity**: `O(n*(2^n))`, where `n` is the dimension of the vector.
    private func getIndexInChildren(_ point: V, relativeTo originalPoint: V) -> Int {
        // var index = 0
        // for i in 0..<V.scalarCount {
        //     if point[i] >= originalPoint[i] {  // isOnHigherRange in this dimension
        //         index |= (1 << i)
        //     }
        // }
        // return index

        let mask = point .>= originalPoint
        
        return (mask[0] ? 1 : 0) | (mask[1] ? 2 : 0) | (mask[2] ? 4 : 0)
    }

}

extension Octree where D.NodeID == Int {

    /// Initialize a NDTree with a list of points and a key path to the vector.
    /// - Parameters: 
    ///  - points: A list of points. The points are only used to calculate the covering box. You should still call `add` to add the points to the tree.
    ///  - clusterDistance: If 2 points are close enough, they will be clustered into the same leaf node.
    ///  - buildRootDelegate: A closure that tells the tree how to initialize the data you want to store in the root.
    ///                  The closure is called only once. The `NDTreeDelegate` will then be created in children tree nods by calling `spawn` on the root delegate.
    public convenience init(
        covering points: [V],
        clusterDistance: V.Scalar,
        buildRootDelegate: () -> D
    ) {
        let coveringBox = Box.cover(of: points)
        self.init(
            box: coveringBox, clusterDistance: clusterDistance, buildRootDelegate: buildRootDelegate
        )
        for i in points.indices {
            add(i, at: points[i])
        }
    }

    /// Initialize a NDTree with a list of points and a key path to the vector.
    /// - Parameters: 
    ///  - points: A list of points. The points are only used to calculate the covering box. You should still call `add` to add the points to the tree.
    ///  - keyPath: A key path to the vector in the element of the list.
    ///  - clusterDistance: If 2 points are close enough, they will be clustered into the same leaf node.
    ///  - buildRootDelegate: A closure that tells the tree how to initialize the data you want to store in the root.
    ///                  The closure is called only once. The `NDTreeDelegate` will then be created in children tree nods by calling `spawn` on the root delegate.
    public convenience init<T>(
        covering points: [T],
        keyPath: KeyPath<T, V>,
        clusterDistance: V.Scalar,
        buildRootDelegate: () -> D
    ) {
        let coveringBox = Box.cover(of: points, keyPath: keyPath)
        self.init(
            box: coveringBox, clusterDistance: clusterDistance, buildRootDelegate: buildRootDelegate
        )
        for i in points.indices {
            add(i, at: points[i][keyPath: keyPath])
        }
    }
}

extension Octree {

    /// The bounding box of the current node
    @inlinable public var extent: Box { box }

    /// Returns true is the current tree node is leaf. Does not guarantee that the tree node has point in it.
    @inlinable public var isLeaf: Bool { children == nil }

    /// Returns true is the current tree node is internal. Internal tree node are always empty and do not contain any points.
    @inlinable public var isInternalNode: Bool { children != nil }

    /// Returns true is the current tree node is leaf and has point in it.
    @inlinable public var isFilledLeaf: Bool { nodePosition != nil }

    /// Returns true is the current tree node is leaf and does not have point in it.
    @inlinable public var isEmptyLeaf: Bool { nodePosition == nil }


    public func visit(shouldVisitChildren: (Octree) -> Bool) {
        if shouldVisitChildren(self), let children {
            // this is an internal node
            for t in children { 
                t.visit(shouldVisitChildren: shouldVisitChildren)
            }
        }
    }
}
