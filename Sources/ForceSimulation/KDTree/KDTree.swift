//
//  KDTree.swift
//
//
//  Created by li3zhen1 on 10/14/23.
//
import simd

/// The data structure carried by a node of KDTree.
///
/// It receives notifications when a node is added or removed on a node, regardless of whether the node is internal or leaf.
/// It is designed to calculate properties like a box's center of mass.
public protocol KDTreeDelegate<NodeID, Vector> {
    associatedtype NodeID: Hashable
    associatedtype Vector: SIMD where Vector.Scalar: FloatingPoint & ExpressibleByFloatLiteral

    /// Called when a node is added on a node, regardless of whether the node is internal or leaf.
    ///
    /// If you add `n` points to the root, this method will be called `n` times in the root delegate,
    /// although it is probably not containing points now.
    /// - Parameters:
    ///   - node: The nodeID of the node that is added.
    ///   - position: The position of the node that is added.
    @inlinable mutating func didAddNode(_ node: NodeID, at position: Vector)

    /// Called when a node is removed on a node, regardless of whether the node is internal or leaf.
    @inlinable mutating func didRemoveNode(_ node: NodeID, at position: Vector)

    /// Copy object.
    ///
    /// This method is called when the root box is not large enough to cover the new nodes.
    @inlinable func copy() -> Self

    /// Create new object with properties set to initial value as if the box is empty.
    ///
    /// However, you can still carry something like a closure to get information from outside.
    /// This method is called when a leaf box is splited due to the insertion of a new node in this box.
    @inlinable func spawn() -> Self
}

/// A node in KDTree
/// - Note: `KDTree` is a generic type that can be used in any dimension.
///        `KDTree` is a reference type.
public final class KDTree<Vector, Delegate>
where
    Vector: SimulatableVector & L2NormCalculatable,
    Delegate: KDTreeDelegate<Int, Vector>
{

    public typealias NodeIndex = Int

    public typealias Direction = Int

    public typealias Box = KDBox<Vector>

    public var box: Box

    public var children: [KDTree<Vector, Delegate>]?

    public var nodePosition: Vector?
    public var nodeIndices: [NodeIndex]

    @inlinable
    public static var clusterDistance: Vector.Scalar {
        return Vector.clusterDistance
    }

    @inlinable
    public static var clusterDistanceSquared: Vector.Scalar {
        return Vector.clusterDistanceSquared
    }

    public var delegate: Delegate

    @inlinable
    init(
        box: Box,
        parentDelegate: Delegate
    ) {
        self.box = box
        self.nodeIndices = []
        self.delegate = parentDelegate.spawn()
    }

    public init(
        box: Box,
        buildRootDelegate: () -> Delegate
    ) {
        self.box = box
        self.nodeIndices = []
        self.delegate = buildRootDelegate()
    }

    public convenience init(
        covering nodes: [NodeIndex: Vector],
        clusterDistance: Vector.Scalar,
        buildRootDelegate: () -> Delegate
    ) {
        let coveringBox = Box.cover(of: Array(nodes.values))
        self.init(
            box: coveringBox,
            buildRootDelegate: buildRootDelegate)
        for (i, p) in nodes {
            add(i, at: p)
        }
    }

    public func add(_ nodeIndex: NodeIndex, at point: Vector) {
        cover(point)
        addWithoutCover(nodeIndex, at: point)
    }

    private func addWithoutCover(_ nodeIndex: NodeIndex, at point: Vector) {
        defer {
            delegate.didAddNode(nodeIndex, at: point)
        }

        guard let children = self.children else {
            if nodePosition == nil {
                nodeIndices.append(nodeIndex)
                nodePosition = point
                return
            } else if nodePosition == point
                || nodePosition!.distanceSquared(to: point) < Self.clusterDistanceSquared
            {
                nodeIndices.append(nodeIndex)
                return
            } else {

                let spawned = Self.spawnChildren(
                    box,
                    //                    Self.directionCount,
                    // clusterDistance,
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
    ///
    /// - Parameter point: The point to be covered.
    private func cover(_ point: Vector) {
        if box.contains(point) { return }

        repeat {
            let direction = getIndexInChildren(point, relativeTo: box.p0)
            expand(towards: direction)
        } while !box.contains(point)
    }

    /// Expand the current node towards a direction.
    ///
    /// The expansion will double the size on each dimension. Then the data in delegate will be copied to the new children.
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
            // clusterDistance,
            /*&*/delegate
        )

        spawned[nailedDirection] = copiedCurrentNode

        self.box = newRootBox
        self.children = spawned
        self.nodeIndices = []
        self.delegate = delegate.copy()

    }

    /// The children count of a node in KDTree.
    ///
    /// Should be equal to the 2^(dimension of the vector).
    /// For example, a 2D vector should have 4 children, a 3D vector should have 8 children.
    /// This property is a getter property but it is probably be inlined.
    @inlinable static var directionCount: Int { 1 << Vector.scalarCount }

    private static func spawnChildren(
        _ _box: Box,
        // _ _clusterDistance: Vector.Scalar,
        _ _delegate: Delegate
    ) -> [KDTree<Vector, Delegate>] {

        var result = [KDTree<Vector, Delegate>]()
        result.reserveCapacity(Self.directionCount)
        let center = _box.center

        for j in 0..<Self.directionCount {
            var __box = _box
            for i in 0..<Vector.scalarCount {
                let isOnTheHigherRange = (j >> i) & 0b1

                // TODO: use simd mask
                if isOnTheHigherRange != 0 {
                    __box.p0[i] = center[i]
                } else {
                    __box.p1[i] = center[i]
                }
            }
            result.append(
                KDTree(
                    box: __box, parentDelegate: /*&*/ _delegate)
            )
        }

        return result
    }

    /// Copy object while holding the same reference to children.
    ///
    /// Consider this function something you would do when working with linked list.
    private func shallowCopy() -> KDTree<Vector, Delegate> {
        let copy = KDTree(
            box: box, parentDelegate: /*&*/ delegate)

        copy.nodeIndices = nodeIndices
        copy.nodePosition = nodePosition
        copy.children = children
        copy.delegate = delegate

        return copy
    }

    /// Get the index of the child that contains the point.
    ///
    /// **Complexity**: `O(n*(2^n))`, where `n` is the dimension of the vector.
    private func getIndexInChildren(_ point: Vector, relativeTo originalPoint: Vector) -> Int {
        var index = 0
        let mask = point .>= originalPoint
        for i in 0..<Vector.scalarCount {
            if mask[i] {  // isOnHigherRange in this dimension
                index |= (1 << i)
            }
        }

        // for i in 0..<Vector.scalarCount {
        //     if point[i] >= originalPoint[i] {  // isOnHigherRange in this dimension
        //         index |= (1 << i)
        //     }
        // }
        return index
    }

}

extension KDTree where Delegate.NodeID == Int {

    /// Initialize a KDTree with a list of points and a key path to the vector.
    ///
    /// - Parameters:
    ///  - points: A list of points. The points are only used to calculate the covering box. You should still call `add` to add the points to the tree.
    ///  - clusterDistance: If 2 points are close enough, they will be clustered into the same leaf node.
    ///  - buildRootDelegate: A closure that tells the tree how to initialize the data you want to store in the root.
    ///                  The closure is called only once. The `NDTreeDelegate` will then be created in children tree nods by calling `spawn` on the root delegate.
    public convenience init(
        covering points: [Vector],
        buildRootDelegate: () -> Delegate
    ) {
        let coveringBox = Box.cover(of: points)
        self.init(
            box: coveringBox, buildRootDelegate: buildRootDelegate
        )
        for i in points.indices {
            add(i, at: points[i])
        }
    }

    /// Initialize a KDTree with a list of points and a key path to the vector.
    ///
    /// - Parameters:
    ///  - points: A list of points. The points are only used to calculate the covering box. You should still call `add` to add the points to the tree.
    ///  - keyPath: A key path to the vector in the element of the list.
    ///  - clusterDistance: If 2 points are close enough, they will be clustered into the same leaf node.
    ///  - buildRootDelegate: A closure that tells the tree how to initialize the data you want to store in the root.
    ///                  The closure is called only once. The `NDTreeDelegate` will then be created in children tree nods by calling `spawn` on the root delegate.
    // public convenience init<T>(
    //     covering points: [T],
    //     keyPath: KeyPath<T, Vector>,
    //     buildRootDelegate: () -> D
    // ) {
    //     let coveringBox = Box.cover(of: points, keyPath: keyPath)
    //     self.init(
    //         box: coveringBox, clusterDistance: clusterDistance, buildRootDelegate: buildRootDelegate
    //     )
    //     for i in points.indices {
    //         add(i, at: points[i][keyPath: keyPath])
    //     }
    // }
}

extension KDTree {

    /// The bounding box of the current node
    @inlinable public var extent: Box { box }

    /// Returns true is the current tree node is leaf.
    ///
    /// Does not guarantee that the tree node has point in it.
    @inlinable public var isLeaf: Bool { children == nil }

    /// Returns true is the current tree node is internal.
    ///
    /// Internal tree node are always empty and do not contain any points.
    @inlinable public var isInternalNode: Bool { children != nil }

    /// Returns true is the current tree node is leaf and has point in it.
    @inlinable public var isFilledLeaf: Bool { nodePosition != nil }

    /// Returns true is the current tree node is leaf and does not have point in it.
    @inlinable public var isEmptyLeaf: Bool { nodePosition == nil }

    /// Visit the tree in pre-order.
    ///
    /// - Parameter shouldVisitChildren: a closure that returns a boolean value indicating whether should continue to visit children.
    @inlinable public func visit(shouldVisitChildren: (KDTree<Vector, Delegate>) -> Bool) {
        if shouldVisitChildren(self), let children {
            // this is an internal node
            for t in children {
                t.visit(shouldVisitChildren: shouldVisitChildren)
            }
        }
    }

    /// Visit the tree in post-order.
    ///
    /// - Parameter action: a closure that takes a tree as its argument.
    @inlinable public func visitPostOrdered(
        _ action: (KDTree<Vector, Delegate>) -> Void
    ) {
        if let children {
            for c in children {
                c.visitPostOrdered(action)
            }
        }
        action(self)
    }
}
