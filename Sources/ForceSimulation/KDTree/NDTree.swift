public struct NDTree<V, D>
where
    V: SimulatableVector & L2NormCalculatable,
    D: KDTreeDelegate<Int, V>
{
    public typealias NodeIndex = D.NodeID
    public typealias Direction = Int
    public typealias Box = KDBox<V>

    public var box: Box
    public var children: [NDTree<V, D>]?
    public var nodePosition: V?
    public var nodeIndices: [NodeIndex]

    // public let clusterDistance: V.Scalar
    @inlinable var clusterDistanceSquared: V.Scalar {
        return V.clusterDistanceSquared
    }

    public var delegate: D

    @inlinable
    public init(
        box: Box,
        // clusterDistanceSquared: V.Scalar,
        spawnedDelegateBeingConsumed: __owned D
    ) {
        self.box = box
        // self.clusterDistanceSquared = clusterDistanceSquared
        self.nodeIndices = []
        self.delegate = consume spawnedDelegateBeingConsumed
    }

    @inlinable
    init(
        box: Box,
        // clusterDistanceSquared: V.Scalar,
        spawnedDelegateBeingConsumed: __owned D,
        childrenBeingConsumed: __owned [NDTree<V, D>]
    ) {
        self.box = box
        // self.clusterDistanceSquared = clusterDistanceSquared
        self.nodeIndices = []
        self.delegate = consume spawnedDelegateBeingConsumed
        self.children = consume childrenBeingConsumed
    }

    @inlinable
    static var directionCount: Int { 1 << V.scalarCount }

    @inlinable
    mutating func cover(_ point: V) {
        if box.contains(point) { return }

        repeat {
            let direction = getIndexInChildren(point, relativeTo: box.p0)
            expand(towards: direction)
        } while !box.contains(point)
    }

    /// Get the index of the child that contains the point.
    ///
    /// **Complexity**: `O(n*(2^n))`, where `n` is the dimension of the vector.
    @inlinable
    func getIndexInChildren(_ point: V, relativeTo originalPoint: V) -> Int {
        var index = 0
        // for i in 0..<V.scalarCount {
        //     if point[i] >= originalPoint[i] {  // isOnHigherRange in this dimension
        //         index |= (1 << i)
        //     }
        // }

        let mask = point .>= originalPoint
        for i in 0..<V.scalarCount {
            if mask[i] {  // isOnHigherRange in this dimension
                index |= (1 << i)
            }
        }
        return index
    }

    @inlinable
    mutating /*__consuming*/ func expand(towards direction: Direction) {
        let nailedDirection = (Self.directionCount - 1) - direction
        let nailedCorner = box.getCorner(of: nailedDirection)
        let _corner = box.getCorner(of: direction)
        let expandedCorner = (_corner + _corner) - nailedCorner
        let newRootBox = Box(nailedCorner, expandedCorner)

        // let clusterDistanceSquared = self.clusterDistanceSquared
        // let _delegate = delegate
        let spawned = delegate.spawn()

        // Dont reference self anymore
        //        let tempSelf = consume self

        var result = [NDTree<V, D>]()
        result.reserveCapacity(Self.directionCount)
        //        let center = newRootBox.center

        for j in 0..<Self.directionCount {

            var __box = newRootBox
            for i in 0..<V.scalarCount {
                let isOnTheHigherRange = (j >> i) & 0b1

                // TODO: use simd mask
                if isOnTheHigherRange != 0 {
                    __box.p0[i] = _corner[i]
                } else {
                    __box.p1[i] = _corner[i]
                }
            }
            result.append(
                Self(
                    box: __box,
                    // clusterDistanceSquared: clusterDistanceSquared,
                    spawnedDelegateBeingConsumed: j != nailedDirection ? self.delegate : spawned
                )
            )
        }

        //        result[nailedDirection] = consume tempSelf

        self = Self(
            box: newRootBox,
            // clusterDistanceSquared: clusterDistanceSquared,
            spawnedDelegateBeingConsumed: self.delegate,
            childrenBeingConsumed: consume result
        )

    }

    @inlinable
    public mutating func add(_ nodeIndex: NodeIndex, at point: V) {
        cover(point)
        addWithoutCover(nodeIndex, at: point)
    }

    @inlinable
    public mutating func addWithoutCover(_ nodeIndex: NodeIndex, at point: V) {
        defer {
            delegate.didAddNode(nodeIndex, at: point)
        }

        guard children != nil else {
            if nodePosition == nil {
                nodeIndices.append(nodeIndex)
                nodePosition = point
                return
            } else if nodePosition == point
                || nodePosition!.distanceSquared(to: point) < clusterDistanceSquared
            {
                nodeIndices.append(nodeIndex)
                return
            } else {

                var spawnedChildren = [NDTree<V, D>]()
                spawnedChildren.reserveCapacity(Self.directionCount)
                let spawendDelegate = self.delegate.spawn()
                let center = box.center

                for j in 0..<Self.directionCount {
                    var __box = self.box
                    for i in 0..<V.scalarCount {
                        let isOnTheHigherRange = (j >> i) & 0b1

                        // TODO: use simd mask
                        if isOnTheHigherRange != 0 {
                            __box.p0[i] = center[i]
                        } else {
                            __box.p1[i] = center[i]
                        }
                    }
                    spawnedChildren.append(
                        Self(
                            box: __box,
                            // clusterDistanceSquared: clusterDistanceSquared,
                            spawnedDelegateBeingConsumed: spawendDelegate
                        )
                    )
                }

                if let nodePosition {
                    let direction = getIndexInChildren(nodePosition, relativeTo: box.center)
                    spawnedChildren[direction].nodeIndices = self.nodeIndices
                    spawnedChildren[direction].nodePosition = self.nodePosition
                    spawnedChildren[direction].delegate = self.delegate
                    self.nodeIndices = []
                    self.nodePosition = nil
                    // TODO: Consume
                }

                let directionOfNewNode = getIndexInChildren(point, relativeTo: box.center)
                spawnedChildren[directionOfNewNode].addWithoutCover(nodeIndex, at: point)

                self.children = spawnedChildren
                return

            }
        }

        let directionOfNewNode = getIndexInChildren(point, relativeTo: box.center)
        self.children![directionOfNewNode].addWithoutCover(nodeIndex, at: point)
        return
    }
}

extension NDTree where D.NodeID == Int {

    /// Initialize a KDTree with a list of points and a key path to the vector.
    ///
    /// - Parameters:
    ///  - points: A list of points. The points are only used to calculate the covering box. You should still call `add` to add the points to the tree.
    ///  - clusterDistance: If 2 points are close enough, they will be clustered into the same leaf node.
    ///  - buildRootDelegate: A closure that tells the tree how to initialize the data you want to store in the root.
    ///                  The closure is called only once. The `NDTreeDelegate` will then be created in children tree nods by calling `spawn` on the root delegate.
    @inlinable
    public init(
        covering points: [V],
        buildRootDelegate: () -> D
    ) {
        let coveringBox = Box.cover(of: points)
        self.init(
            box: coveringBox, spawnedDelegateBeingConsumed: buildRootDelegate()
        )
        for i in points.indices {
            add(i, at: points[i])
        }
    }

    @inlinable
    public init(
        covering points: UnsafeArray<V>,
        buildRootDelegate: () -> D
    ) {
        let coveringBox = Box.cover(of: points)
        self.init(
            box: coveringBox, spawnedDelegateBeingConsumed: buildRootDelegate()
        )
        for i in 0..<points.header {
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

extension NDTree {

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
    @inlinable public mutating func visit(shouldVisitChildren: (inout NDTree<V, D>) -> Bool) {
        if shouldVisitChildren(&self) && children != nil {
            // this is an internal node
            for i in children!.indices {
                children![i].visit(shouldVisitChildren: shouldVisitChildren)
            }
        }
    }

    /// Visit the tree in post-order.
    ///
    /// - Parameter action: a closure that takes a tree as its argument.
    @inlinable public func visitPostOrdered(
        _ action: (NDTree<V, D>) -> Void
    ) {
        if let children {
            for c in children {
                c.visitPostOrdered(action)
            }
        }
        action(self)
    }
}
