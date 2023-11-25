/// A node in NDTree
/// - Note: `NDTree` is a generic type that can be used in any dimension.
///        `NDTree` is a value type.
public struct KDTree<Vector, Delegate>
where
    Vector: SimulatableVector & L2NormCalculatable,
    Delegate: KDTreeDelegate<Int, Vector>
{
    public typealias NodeIndex = Delegate.NodeID
    public typealias Direction = Int
    public typealias Box = KDBox<Vector>

    public var box: Box
    public var children: [KDTree<Vector, Delegate>]?
    public var nodePosition: Vector?
    public var nodeIndices: [NodeIndex]

    // public let clusterDistance: Vector.Scalar
    @inlinable var clusterDistanceSquared: Vector.Scalar {
        return Vector.clusterDistanceSquared
    }

    public var delegate: Delegate

    @inlinable
    public init(
        box: Box,
        // clusterDistanceSquared: Vector.Scalar,
        spawnedDelegateBeingConsumed: consuming Delegate
    ) {
        self.box = box
        // self.clusterDistanceSquared = clusterDistanceSquared
        self.nodeIndices = []
        self.delegate = consume spawnedDelegateBeingConsumed
    }

    @inlinable
    init(
        box: Box,
        // clusterDistanceSquared: Vector.Scalar,
        spawnedDelegateBeingConsumed: consuming Delegate,
        childrenBeingConsumed: consuming [KDTree<Vector, Delegate>]
    ) {
        self.box = box
        // self.clusterDistanceSquared = clusterDistanceSquared
        self.nodeIndices = []
        self.delegate = consume spawnedDelegateBeingConsumed
        self.children = consume childrenBeingConsumed
    }

    @inlinable
    static var directionCount: Int { 1 << Vector.scalarCount }

    @inlinable
    mutating func cover(_ point: Vector) {
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
    func getIndexInChildren(_ point: Vector, relativeTo originalPoint: Vector) -> Int {
        var index = 0

        let mask = point .>= originalPoint

        for i in 0..<Vector.scalarCount {
            if mask[i] {  // isOnHigherRange in this dimension
                index |= (1 << i)
            }
        }
        return index
    }

    /// Expand the current node towards a direction. 
    ///
    /// The expansion will double the size on each dimension. Then the data in delegate will be copied to the new children.
    /// - Parameter direction: An Integer between 0 and `directionCount - 1`, where `directionCount` equals to 2^(dimension of the vector).
    @inlinable
    mutating func expand(towards direction: Direction) {
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

        var result = [KDTree<Vector, Delegate>]()
        result.reserveCapacity(Self.directionCount)
        //        let center = newRootBox.center

        for j in 0..<Self.directionCount {

            var __box = newRootBox
            for i in 0..<Vector.scalarCount {
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
    public mutating func add(_ nodeIndex: NodeIndex, at point: Vector) {
        cover(point)
        addWithoutCover(nodeIndex, at: point)
    }
    
    @inlinable
    public mutating func addWithoutCover(_ nodeIndex: NodeIndex, at point: Vector) {
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

                var spawnedChildren = [KDTree<Vector, Delegate>]()
                spawnedChildren.reserveCapacity(Self.directionCount)
                let spawendDelegate = self.delegate.spawn()
                let center = box.center

                for j in 0..<Self.directionCount {
                    var __box = self.box
                    for i in 0..<Vector.scalarCount {
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

extension KDTree where Delegate.NodeID == Int {

    /// Initialize a KDTree with a list of points and a key path to the vector.
    ///
    /// - Parameters:
    ///  - points: A list of points. The points are only used to calculate the covering box. You should still call `add` to add the points to the tree.
    ///  - clusterDistance: If 2 points are close enough, they will be clustered into the same leaf node.
    ///  - buildRootDelegate: A closure that tells the tree how to initialize the data you want to store in the root.
    ///                  The closure is called only once. The `NDTreeDelegate` will then be created in children tree nods by calling `spawn` on the root delegate.
    @inlinable
    public init(
        covering points: [Vector],
        buildRootDelegate: () -> Delegate
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
        covering points: UnsafeArray<Vector>,
        buildRootDelegate: () -> Delegate
    ) {
        let coveringBox = Box.cover(of: points)
        self.init(
            box: coveringBox, spawnedDelegateBeingConsumed: buildRootDelegate()
        )
        for i in 0..<points.header {
            add(i, at: points[i])
        }
    }

    @inlinable
    public init(
        covering points: UnsafeArray<Vector>,
        rootDelegate: @autoclosure () -> Delegate
    ) {
        let coveringBox = Box.cover(of: points)
        self.init(
            box: coveringBox, spawnedDelegateBeingConsumed: rootDelegate()
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
    //     buildRootDelegate: () -> Delegate
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
    @inlinable public mutating func visit(shouldVisitChildren: (inout KDTree<Vector, Delegate>) -> Bool) {
        if shouldVisitChildren(&self) && children != nil {
            // this is an internal node
            for i in children!.indices {
                children![i].visit(shouldVisitChildren: shouldVisitChildren)
            }
        }
    }

}


// public struct KDTreeRoot<Vector, Delegate, Property>
// where
//     Vector: SimulatableVector & L2NormCalculatable,
//     Delegate: KDTreeDelegate<Int, Vector>
// {
//     public var root: KDTree<Vector, Delegate>
//     @usableFromInline let propertyBuffer: UnsafeMutablePointer<Property>

//     @inlinable
//     public init(
//         root: KDTree<Vector, Delegate>,
//         propertyBuffer: UnsafeMutablePointer<Property>
//     ) {
//         self.root = root
//         self.propertyBuffer = propertyBuffer
//     }


//     @inlinable
//     public mutating func add(_ nodeIndex: Int, at point: Vector) {
//         root.cover(point)
//         root.addWithoutCover(nodeIndex, at: point)
//     }
// }