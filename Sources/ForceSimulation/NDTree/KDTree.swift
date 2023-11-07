public struct KDTree<V, D> where V: VectorLike, D: NDTreeDelegate, D.V == V {
    
    public typealias NodeIndex = D.NodeID
    public typealias Direction = Int
    public typealias Box = NDBox<V>
    
    public var box: Box
    public var children: [KDTree<V, D>]?
    public var nodePosition: V?
    public var nodeIndices: [NodeIndex]
    
    // public let clusterDistance: V.Scalar
    @usableFromInline let clusterDistanceSquared: V.Scalar
    
    public var delegate: D
    
    @inlinable
    public init(
        box: Box,
        clusterDistanceSquared: V.Scalar,
        spawnedDelegateBeingConsumed: __owned D
    ) {
        self.box = box
        self.clusterDistanceSquared = clusterDistanceSquared
        self.nodeIndices = []
        self.delegate = consume spawnedDelegateBeingConsumed
    }
    
    @inlinable
    init(
        box: Box,
        clusterDistanceSquared: V.Scalar,
        spawnedDelegateBeingConsumed: __owned D,
        childrenBeingConsumed: __owned [KDTree<V, D>]
    ) {
        self.box = box
        self.clusterDistanceSquared = clusterDistanceSquared
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
        for i in 0..<V.scalarCount {
            if point[i] >= originalPoint[i] {  // isOnHigherRange in this dimension
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
        
        let clusterDistanceSquared = self.clusterDistanceSquared
        let _delegate = delegate
        let spawned = delegate.spawn()
        
        // Dont reference self anymore
//        let tempSelf = consume self
        
        
        var result = Array<KDTree<V, D>>()
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
            result.append (
                Self(
                    box: __box,
                    clusterDistanceSquared: clusterDistanceSquared,
                    spawnedDelegateBeingConsumed: j != nailedDirection ? self.delegate : spawned
                )
            )
        }
        
//        result[nailedDirection] = consume tempSelf
        
        self = Self(
            box: newRootBox,
            clusterDistanceSquared: clusterDistanceSquared,
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
                
                var spawnedChildren = Array<KDTree<V, D>>()
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
                            clusterDistanceSquared: clusterDistanceSquared,
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
