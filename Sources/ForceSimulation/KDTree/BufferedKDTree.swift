public struct KDTreeNode<Vector, Delegate>
where
    Vector: SimulatableVector & L2NormCalculatable,
    Delegate: KDTreeDelegate<Int, Vector>
{
    public struct NodeIndex {

        @usableFromInline
        var index: Int

        @usableFromInline
        var next: UnsafeMutablePointer<NodeIndex>?

    }
    public var box: KDBox<Vector>
    public var nodePosition: Vector
    public var childrenBufferPointer: UnsafeMutablePointer<KDTreeNode>?

    public var nodeIndices: NodeIndex?
    public var delegate: Delegate

    @inlinable
    init(
        nodeIndices: NodeIndex?,
        childrenBufferPointer: UnsafeMutablePointer<KDTreeNode>?,
        delegate: consuming Delegate,
        box: consuming KDBox<Vector>
    ) {
        self.childrenBufferPointer = childrenBufferPointer
        self.nodeIndices = nodeIndices
        self.delegate = consume delegate
        self.box = consume box
        self.nodePosition = .zero
    }

}

public struct BufferedKDTree<Vector, Delegate>
where
    Vector: SimulatableVector & L2NormCalculatable,
    Delegate: KDTreeDelegate<Int, Vector>
{
    public typealias Box = KDBox<Vector>
    public typealias TreeNode = KDTreeNode<Vector, Delegate>

    @usableFromInline
    internal var rootPointer: UnsafeMutablePointer<TreeNode>

    @usableFromInline
    internal var validCount: Int = 0

    @usableFromInline
    internal var treeNodeBuffer: UnsafeArray<TreeNode>

    @inlinable
    static internal var clusterDistanceSquared: Vector.Scalar {
        return Vector.clusterDistanceSquared
    }

    @inlinable
    public var root: TreeNode { rootPointer.pointee }

    @inlinable
    public init(
        rootBox: Box,
        nodeCapacity: Int,
        rootDelegate: @autoclosure () -> Delegate
    ) {
        let maxBufferCount = (nodeCapacity << Vector.scalarCount) + 1
        let zeroNode: TreeNode = .init(
            nodeIndices: nil,
            childrenBufferPointer: nil,
            delegate: rootDelegate(),
            box: rootBox
        )
        treeNodeBuffer = .createBuffer(
            withHeader: maxBufferCount,
            count: maxBufferCount,
            initialValue: zeroNode
        )
        rootPointer = treeNodeBuffer.withUnsafeMutablePointerToElements { $0 }

        rootPointer.pointee = .init(
            nodeIndices: nil,
            childrenBufferPointer: nil,
            delegate: rootDelegate(),
            box: rootBox
        )
        self.validCount = 1
    }

    @inlinable
    public mutating func reset(
        rootBox: Box,
        rootDelegate: @autoclosure () -> Delegate
    ) {
        rootPointer.pointee = .init(
            nodeIndices: nil,
            childrenBufferPointer: nil,
            delegate: rootDelegate(),
            box: rootBox
        )
        self.validCount = 1
    }

    @inlinable
    internal mutating func resize(
        to newTreeNodeBufferSize: Int
    ) {
        assert(newTreeNodeBufferSize >= treeNodeBuffer.header)
        let newTreeNodeBuffer = UnsafeArray<TreeNode>.createBuffer(
            withHeader: newTreeNodeBufferSize,
            count: newTreeNodeBufferSize,
            initialValue: .init(
                nodeIndices: nil,
                childrenBufferPointer: nil,
                delegate: root.delegate,
                box: root.box
            )
        )
        newTreeNodeBuffer.withUnsafeMutablePointerToElements {
            $0.moveInitialize(
                from: treeNodeBuffer.withUnsafeMutablePointerToElements { $0 }, count: validCount)
        }
        treeNodeBuffer = newTreeNodeBuffer
        rootPointer = treeNodeBuffer.withUnsafeMutablePointerToElements { $0 }
    }

    @inlinable
    internal mutating func resizeIfNeededBeforeAllocation(for count: Int) {
        if validCount + Self.directionCount > treeNodeBuffer.count {
            let factor = (count / self.treeNodeBuffer.count) + 1
            resize(to: treeNodeBuffer.header * factor)
        }
    }

    @inlinable
    public mutating func add(
        nodeIndex: Int,
        at point: Vector
    ) {
        assert(validCount > 0)
        cover(point: point)
        addWithoutCover(
            onTreeNode: rootPointer,
            nodeOf: nodeIndex,
            at: point
        )
    }

    @inlinable
    internal mutating func addWithoutCover(
        onTreeNode treeNode: UnsafeMutablePointer<TreeNode>,
        nodeOf nodeIndex: Int,
        at point: Vector
    ) {

        defer {
            treeNode.pointee.delegate.didAddNode(nodeIndex, at: point)
        }
        guard treeNode.pointee.childrenBufferPointer != nil else {
            if treeNode.pointee.nodeIndices == nil {
                treeNode.pointee.nodeIndices = .init(nodeIndex: nodeIndex)
                treeNode.pointee.nodePosition = point
                return
            } else if treeNode.pointee.nodePosition.distanceSquared(to: point)
                < Self.clusterDistanceSquared
            {
                treeNode.pointee.nodeIndices!.append(nodeIndex: nodeIndex)
                return
            } else {

                let spawnedDelegate = treeNode.pointee.delegate.spawn()
                let center = treeNode.pointee.box.center

                resizeIfNeededBeforeAllocation(for: Self.directionCount)

                for j in 0..<Self.directionCount {
                    var __box = treeNode.pointee.box

                    for i in 0..<Vector.scalarCount {
                        let isOnTheHigherRange = (j >> i) & 0b1
                        // TODO: use simd mask
                        if isOnTheHigherRange != 0 {
                            __box.p0[i] = center[i]
                        } else {
                            __box.p1[i] = center[i]
                        }
                    }

                    treeNodeBuffer[validCount + j] = .init(
                        nodeIndices: nil,
                        childrenBufferPointer: nil,
                        delegate: spawnedDelegate,
                        box: __box
                    )

                }
                treeNode.pointee.childrenBufferPointer = rootPointer + validCount
                validCount += Self.directionCount

                if let childrenBufferPointer = treeNode.pointee.childrenBufferPointer {
                    let direction = getIndexInChildren(
                        treeNode.pointee.nodePosition,
                        relativeTo: center
                    )

                    childrenBufferPointer[direction].nodeIndices = treeNode.pointee.nodeIndices
                    childrenBufferPointer[direction].nodePosition = treeNode.pointee.nodePosition
                    childrenBufferPointer[direction].delegate = treeNode.pointee.delegate
                    treeNode.pointee.nodeIndices = nil
                    treeNode.pointee.nodePosition = .zero
                }

                let directionOfNewNode = getIndexInChildren(point, relativeTo: center)
                // spawnedChildren[directionOfNewNode].addWithoutCover(nodeIndex, at: point)
                addWithoutCover(
                    onTreeNode: treeNode.pointee.childrenBufferPointer! + directionOfNewNode,
                    nodeOf: nodeIndex,
                    at: point
                )

                // self.children = spawnedChildren
                return

            }
        }

        let directionOfNewNode = getIndexInChildren(point, relativeTo: treeNode.pointee.box.center)
        self.addWithoutCover(
            onTreeNode: treeNode.pointee.childrenBufferPointer! + directionOfNewNode,
            nodeOf: nodeIndex,
            at: point
        )
        return
    }

    @inlinable
    internal mutating func cover(point: Vector) {
        if self.root.box.contains(point) { return }

        repeat {
            let direction = self.getIndexInChildren(point, relativeTo: self.root.box.p0)
            self.expand(towards: direction)
        } while !self.root.box.contains(point)
    }

    @inlinable
    internal mutating func expand(towards direction: Int) {
        let nailedDirection = (Self.directionCount - 1) - direction
        let nailedCorner = self.root.box.getCorner(of: nailedDirection)
        let _corner = self.root.box.getCorner(of: direction)
        let expandedCorner = (_corner + _corner) - nailedCorner
        let newRootBox = Box(nailedCorner, expandedCorner)

        let _rootValue = self.root

        // spawn the delegate with the same internal values
        // for the children, use implicit copy of spawned
        let spawned = _rootValue.delegate.spawn()

        let newChildrenPointer = self.rootPointer + validCount

        resizeIfNeededBeforeAllocation(for: Self.directionCount)

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

            self.treeNodeBuffer[validCount + j] = .init(
                nodeIndices: nil,
                childrenBufferPointer: nil,
                delegate: j != nailedDirection ? _rootValue.delegate : spawned,
                box: __box
            )
        }
        self.validCount += Self.directionCount

        self.rootPointer.pointee = .init(
            nodeIndices: nil,
            childrenBufferPointer: newChildrenPointer,
            delegate: _rootValue.delegate,
            box: newRootBox
        )
    }

    @inlinable
    static internal var directionCount: Int { 1 << Vector.scalarCount }

    @inlinable
    internal func deinitializeBuffer() {
        _ = treeNodeBuffer.withUnsafeMutablePointerToElements {
            $0.deinitialize(count: Self.directionCount)
        }
    }

    /// Get the index of the child that contains the point.
    ///
    /// **Complexity**: `O(n*(2^n))`, where `n` is the dimension of the vector.
    @inlinable
    internal func getIndexInChildren(_ point: Vector, relativeTo originalPoint: Vector) -> Int {
        var index = 0

        let mask = point .>= originalPoint

        for i in 0..<Vector.scalarCount {
            if mask[i] {  // isOnHigherRange in this dimension
                index |= (1 << i)
            }
        }
        return index
    }
}

extension BufferedKDTree {

    /// The bounding box of the current node
    @inlinable public var extent: Box { self.root.box }

    /// Visit the tree in pre-order.
    ///
    /// - Parameter shouldVisitChildren: a closure that returns a boolean value indicating whether should continue to visit children.
    @inlinable public func visit(
        shouldVisitChildren: (inout KDTreeNode<Vector, Delegate>) -> Bool
    ) {
        rootPointer.pointee.visit(shouldVisitChildren: shouldVisitChildren)
    }

}

extension KDTreeNode.NodeIndex {

    @inlinable
    internal init(
        nodeIndex: Int
    ) {
        self.index = nodeIndex
        self.next = nil
    }

    @inlinable
    internal mutating func append(nodeIndex: Int) {
        if let next {
            next.pointee.append(nodeIndex: nodeIndex)
        } else {
            next = .allocate(capacity: 1)
            next!.initialize(to: .init(nodeIndex: nodeIndex))
            // next!.pointee = .init(nodeIndex: nodeIndex)
        }
    }

    @inlinable
    internal func deinitialize() {
        if let next {
            next.pointee.deinitialize()
            next.deallocate()
        }
    }

    @inlinable
    internal func contains(_ nodeIndex: Int) -> Bool {
        if index == nodeIndex { return true }
        if let next {
            return next.pointee.contains(nodeIndex)
        } else {
            return false
        }
    }

    @inlinable
    internal func forEach(_ body: (Int) -> Void) {
        body(index)
        if let next {
            next.pointee.forEach(body)
        }
    }
}

extension KDTreeNode {
    /// Returns true is the current tree node is leaf.
    ///
    /// Does not guarantee that the tree node has point in it.
    @inlinable public var isLeaf: Bool { childrenBufferPointer == nil }

    /// Returns true is the current tree node is internal.
    ///
    /// Internal tree node are always empty and do not contain any points.
    @inlinable public var isInternalNode: Bool { childrenBufferPointer != nil }

    /// Returns true is the current tree node is leaf and has point in it.
    @inlinable public var isFilledLeaf: Bool { nodeIndices != nil }

    /// Returns true is the current tree node is leaf and does not have point in it.
    @inlinable public var isEmptyLeaf: Bool { nodeIndices == nil }

    /// Visit the tree in pre-order.
    ///
    /// - Parameter shouldVisitChildren: a closure that returns a boolean value indicating whether should continue to visit children.
    @inlinable public mutating func visit(
        shouldVisitChildren: (inout KDTreeNode<Vector, Delegate>) -> Bool
    ) {
        if shouldVisitChildren(&self) && childrenBufferPointer != nil {
            // this is an internal node
            for i in 0..<BufferedKDTree<Vector, Delegate>.directionCount {
                childrenBufferPointer![i].visit(shouldVisitChildren: shouldVisitChildren)
            }
        }
    }
}