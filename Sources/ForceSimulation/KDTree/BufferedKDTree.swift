public struct BufferedKDTree<Vector, Delegate>: Disposable
where
    Vector: SimulatableVector & L2NormCalculatable,
    Delegate: KDTreeDelegate<Int, Vector>
{
    public typealias Box = KDBox<Vector>
    public typealias TreeNode = KDTreeNode<Vector, Delegate>

    @usableFromInline
    internal var rootPointer: UnsafeMutablePointer<TreeNode> {
        treeNodeBuffer.mutablePointer
    }

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
        // Assuming each add creates 2^Vector.scalarCount nodes
        // In most situations this is sufficient (for example the miserable graph)
        // But It's possible to exceed this limit:
        // 2 additions very close but not clustered in the same box
        // In this case there's no upperbound for addition so `resize` is needed
        let maxBufferCount = (nodeCapacity << Vector.scalarCount) + 1
        self.rootDelegate = rootDelegate()

        treeNodeBuffer = .createBuffer(
            withHeader: maxBufferCount,
            count: maxBufferCount,
            initialValue: .zeroWithDelegate(self.rootDelegate)
        )
        rootPointer.pointee = TreeNode(
            nodeIndices: nil,
            childrenBufferPointer: nil,
            delegate: self.rootDelegate,
            box: rootBox
        )
        self.validCount = 1
    }

    @usableFromInline
    internal var rootDelegate: Delegate

    @inlinable
    public mutating func reset(
        rootBox: Box,
        rootDelegate: @autoclosure () -> Delegate
    ) {
        self.rootDelegate = rootDelegate()

        treeNodeBuffer.withUnsafeMutablePointerToElements {
            for i in 0..<validCount {
                $0[i].disposeNodeIndices()
            }
        }
        rootPointer.pointee = .init(
            nodeIndices: nil,
            childrenBufferPointer: nil,
            delegate: self.rootDelegate,
            box: rootBox
        )
        self.validCount = 1
    }

    @inlinable
    internal mutating func resize(
        to newTreeNodeBufferSize: Int
    ) {

        #if DEBUG

            assert(newTreeNodeBufferSize > treeNodeBuffer.header)
            let rootCopy = root
        #endif
        let oldRootPointer = rootPointer

        let newTreeNodeBuffer = UnsafeArray<TreeNode>.createBuffer(
            withHeader: newTreeNodeBufferSize,
            count: newTreeNodeBufferSize,
            moving: treeNodeBuffer.mutablePointer,
            movingCount: validCount,
            fillingExcessiveBufferWith: .zeroWithDelegate(self.rootDelegate)
        )

        let newRootPointer = newTreeNodeBuffer.withUnsafeMutablePointerToElements { $0 }

        for i in 0..<validCount {
            if newTreeNodeBuffer[i].childrenBufferPointer != nil {
                newTreeNodeBuffer[i].childrenBufferPointer! =
                    newRootPointer + (newTreeNodeBuffer[i].childrenBufferPointer! - oldRootPointer)
            }
        }

        // self.rootPointer = newRootPointer
        self.treeNodeBuffer = newTreeNodeBuffer

        #if DEBUG
            assert(rootCopy.box == root.box)
            assert(oldRootPointer != rootPointer)
        #endif
    }

    /// Extend the size of the buffer.
    /// - Parameter count: the number of elements to extend
    /// - Returns: true if the buffer is resized
    @inlinable
    @discardableResult
    internal mutating func resizeIfNeededBeforeAllocation(for count: Int) -> Bool {
        if validCount + count > treeNodeBuffer.count {
            let factor = (count / self.treeNodeBuffer.count) + 2

            resize(to: treeNodeBuffer.count * factor)

            assert(treeNodeBuffer.count >= validCount + count)

            return true
        }
        return false
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
        if treeNode.pointee.childrenBufferPointer != nil {

            let directionOfNewNode = getIndexInChildren(
                point, relativeTo: treeNode.pointee.box.center)
            let treeNodeOffset = (treeNode) - rootPointer
            self.addWithoutCover(
                onTreeNode: treeNode.pointee.childrenBufferPointer! + directionOfNewNode,
                nodeOf: nodeIndex,
                at: point
            )
            rootPointer[treeNodeOffset].delegate.didAddNode(nodeIndex, at: point)
            return

        } else if treeNode.pointee.nodeIndices == nil {
            // empty leaf

            treeNode.pointee.nodeIndices = TreeNode.NodeIndex(nodeIndex)
            treeNode.pointee.nodePosition = point
            treeNode.pointee.delegate.didAddNode(nodeIndex, at: point)

            return
        } else if treeNode.pointee.nodePosition.distanceSquared(to: point)
            > Self.clusterDistanceSquared
        {
            // filled leaf

            let treeNodeOffset = (treeNode) - rootPointer
            resizeIfNeededBeforeAllocation(for: Self.directionCount)
            
            let newTreeNode = self.rootPointer + treeNodeOffset
            
            let spawnedDelegate = newTreeNode.pointee.delegate.spawn()
            let center = newTreeNode.pointee.box.center

            let _box = newTreeNode.pointee.box
            for j in 0..<Self.directionCount {
                var __box = _box
                for i in 0..<Vector.scalarCount {
                    let isOnTheHigherRange = (j >> i) & 0b1
                    if isOnTheHigherRange != 0 {
                        __box.p0[i] = center[i]
                    } else {
                        __box.p1[i] = center[i]
                    }
                }

                let obsoletePtr = self.rootPointer + validCount + j

                obsoletePtr.pointee.disposeNodeIndices()
                obsoletePtr.pointee = TreeNode(
                    nodeIndices: nil,
                    childrenBufferPointer: nil,
                    delegate: spawnedDelegate,
                    box: __box
                )

            }
            newTreeNode.pointee.childrenBufferPointer = rootPointer + validCount
            validCount += Self.directionCount

            if let childrenBufferPointer = newTreeNode.pointee.childrenBufferPointer {
                let direction = getIndexInChildren(
                    newTreeNode.pointee.nodePosition,
                    relativeTo: center
                )
                // newly created, no need to dispose
                // childrenBufferPointer[direction].disposeNodeIndices()
                childrenBufferPointer[direction] = .init(
                    nodeIndices: newTreeNode.pointee.nodeIndices,
                    childrenBufferPointer: childrenBufferPointer[direction]
                        .childrenBufferPointer,
                    delegate: newTreeNode.pointee.delegate,
                    box: childrenBufferPointer[direction].box,
                    nodePosition: newTreeNode.pointee.nodePosition
                )

                newTreeNode.pointee.nodeIndices = nil
                newTreeNode.pointee.nodePosition = .zero
            }

            let directionOfNewNode = getIndexInChildren(point, relativeTo: center)

            // This add might also resize this buffer!
            addWithoutCover(
                onTreeNode: newTreeNode.pointee.childrenBufferPointer! + directionOfNewNode,
                nodeOf: nodeIndex,
                at: point
            )

            rootPointer[treeNodeOffset].delegate.didAddNode(nodeIndex, at: point)
            return
        } else {
            // filled leaf and within cluster distance
            treeNode.pointee.nodeIndices!.append(nodeIndex: nodeIndex)

            treeNode.pointee.delegate.didAddNode(nodeIndex, at: point)
            return
        }

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
            // newly allocated, no need to dispose
            if j != nailedDirection {
                self.treeNodeBuffer[validCount + j] = TreeNode(
                    nodeIndices: nil,
                    childrenBufferPointer: nil,
                    delegate: spawned,
                    box: __box,
                    nodePosition: .zero
                )
            } else {
                self.treeNodeBuffer[validCount + j] = TreeNode(
                    nodeIndices: _rootValue.nodeIndices,
                    childrenBufferPointer: _rootValue.childrenBufferPointer,
                    delegate: _rootValue.delegate,
                    box: __box,
                    nodePosition: _rootValue.nodePosition
                )
            }
        }
        self.validCount += Self.directionCount

        // don't dispose, they are used in treeNodeBuffer[validCount + j]
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
    public func dispose() {
        treeNodeBuffer.withUnsafeMutablePointerToElements {
            for i in 0..<validCount {
                $0[i].disposeNodeIndices()
            }
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
