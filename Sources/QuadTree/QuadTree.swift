// The Swift Programming Language
// https://docs.swift.org/swift-book

// #if arch(wasm32)
// import SimdPolyfill
// #else
import simd
// #endif


final public class QuadTreeNode<NodeID: Hashable> {
    
    public private(set) var quad: Quad
    
    public private(set) var nodes: [NodeID: Vector2f] = [:]  // TODO: merge nodes if close enough

    final public class Children {
        public private(set) var northWest: QuadTreeNode<NodeID>
        public private(set) var northEast: QuadTreeNode<NodeID>
        public private(set) var southWest: QuadTreeNode<NodeID>
        public private(set) var southEast: QuadTreeNode<NodeID>
        internal init(
            _ northWest: QuadTreeNode<NodeID>,
            _ northEast: QuadTreeNode<NodeID>,
            _ southWest: QuadTreeNode<NodeID>,
            _ southEast: QuadTreeNode<NodeID>
        ) {
            self.northWest = northWest
            self.northEast = northEast
            self.southWest = southWest
            self.southEast = southEast
        }


    }
    
    public private(set) var children: Children?
    
    public let clusterDistance: Float
    
    internal init(
        quad: Quad,
        clusterDistance: Float
    ) {
        self.quad = quad
        self.clusterDistance = clusterDistance
    }
    
    public func add(_ node: NodeID, at point: Vector2f) {
        cover(point)
        
        guard let children = self.children else {
            if nodes.isEmpty {
                // no children, not occupied => take this point
                nodes[node] = point
                return
            }
            else if let centroid, centroid.distanceTo(point) < clusterDistance {
                // no children, close enough => take this point
                nodes[node] = point
                return
            }
            else {
                // no children, not close enough => divide & add to children
                let divided = QuadTreeNode.divide(quad: quad, clusterDistance: clusterDistance)

                self.nodes.forEach { n, p in
                    let direction = quad.quadrantOf(p)
                    divided[at: direction].add(n, at: p)
                }
                self.nodes.removeAll()
                        
                let direction = quad.quadrantOf(point)
                divided[at: direction].add(node, at: point)

                self.children = divided
                return
            }
        }
        // has children => add to children
        let direction = quad.quadrantOf(point)
        children[at: direction].add(node, at: point)
    }

    public func traverse(_ body: @escaping (QuadTreeNode<NodeID>) -> Void) {
        body(self)
        children?.forEach { child, _ in
            child.traverse(body)
        }
    }

    public func addAll(_ nodesAndPoints: Dictionary<NodeID, Vector2f>) {
        for (n, p) in nodes {
            add(n, at: p)
        }
    }
    
    @discardableResult
    public func remove(_ node: NodeID) -> Bool {
        if nodes.removeValue(forKey: node) != nil {
            return true
        }
        else {
            guard let children = self.children else {
                return false
            }
            return children.anyMutating { child, _ in
                child.remove(node)
            }
        } 
    }

    public func removeAll() {
        nodes.removeAll()
        children?.forEachMutating { n, _ in
            n.removeAll()
        }
    }

    /// Expand the quad by exponential of 2 to cover the point, does nothing if the point is already covered
    /// Does not add point to the tree
    /// - Parameter point: 
    internal func cover(_ point: Vector2f) {
        if quad.contains(point) {
            return
        }
        else {

            let quadrant = quad.quadrantOf(point)
            let nailedCorner = quad.getCorner(of: quadrant.reversed)
            let expandingCorner = quad.getCorner(of: quadrant)

            let coveredArea = expandingCorner - nailedCorner
            let uncoveredArea = point - nailedCorner

            let scaleX = uncoveredArea.x / coveredArea.x
            let scaleY = uncoveredArea.y / coveredArea.y

#if DEBUG
            assert(scaleX > 0 && scaleY > 0)
#endif

            let expansionTime = Int(ceilf(log2(max(scaleX, scaleY))))

            for _ in 0..<expansionTime {
                expand(towards: quadrant)
            }
        }
    }


    private func expand(towards quadrant: Quadrant) {
        let nailedQuadrant = quadrant.reversed
        let nailedCorner = quad.getCorner(of: nailedQuadrant)
        let expandedCorner = quad.getCorner(of: quadrant) * 2 - nailedCorner
        
        let newRootQuad = Quad(corner: nailedCorner, oppositeCorner: expandedCorner)
        let copiedCurrentNode = shallowCopy()
        let divided = QuadTreeNode.divide(quad: newRootQuad, clusterDistance: clusterDistance)
        divided[at: nailedQuadrant] = copiedCurrentNode

        self.quad = newRootQuad
        self.children = divided
        self.nodes = [:]
    }
    
    private static func divide(quad: Quad, clusterDistance: Float) -> Children {
        let divided = quad.divide()
        let northWest = QuadTreeNode<NodeID>(quad: divided.northWest, clusterDistance: clusterDistance)
        let northEast = QuadTreeNode<NodeID>(quad: divided.northEast, clusterDistance: clusterDistance)
        let southWest = QuadTreeNode<NodeID>(quad: divided.southWest, clusterDistance: clusterDistance)
        let southEast = QuadTreeNode<NodeID>(quad: divided.southEast, clusterDistance: clusterDistance)
        return Children(northWest, northEast, southWest, southEast)
        
        // for (n, p) in nodes {
        //     // TODO: use only centroid? (same complexity)
        //     let direction = quad.quadrantOf(p)
        //     children[at: direction].add(n, at: p)
        // }

        // self.children = children
        // self.nodes.removeAll()
    }
    
    /**
     *  Copy object while holding the same reference to children
     */
    private func shallowCopy() -> QuadTreeNode<NodeID> {
        let copy = QuadTreeNode<NodeID>(quad: quad, clusterDistance: clusterDistance)
        copy.nodes = nodes
        copy.children = children
        return copy
    }

    public var isLeaf: Bool {
        return children == nil
    }
    
    public var centroid: Vector2f? {
        get {
            if isLeaf {
                return nodes.values.sum() / Float(nodes.count)
            }
            return nil
        }
    }
}


enum QuadTreeError: Error {
    case noNodeProvidedError
}

final public class QuadTree<NodeID: Hashable> {
    public private(set) var root: QuadTreeNode<NodeID>
    private var nodeIds: Set<NodeID> = []
    
    public let clusterDistance: Float

    public init(
        quad: Quad,
        clusterDistance: Float = 1e-6
    ) {
        self.clusterDistance = clusterDistance
        self.root = QuadTreeNode<NodeID>(quad: quad, clusterDistance: clusterDistance)
    }

    public init(
        nodes: [(NodeID, Vector2f)],
        clusterDistance: Float = 1e-6
    ) throws {
        guard let firstEntry = nodes.first else {
            throw QuadTreeError.noNodeProvidedError
        }
        self.clusterDistance = clusterDistance
        self.root = QuadTreeNode<NodeID>(
            quad: Quad.cover(firstEntry.1),
            clusterDistance: clusterDistance
        )
        self.addAll(nodes)
    }

    public func add(_ nodeId: NodeID, at point: Vector2f) {
        root.add(nodeId, at: point)
        nodeIds.insert(nodeId)
    }

    public func addAll(_ nodesAndPoints: [(NodeID, Vector2f)]) {
        for (n, p) in nodesAndPoints {
            add(n, at: p)
        }
    }

    public func remove(_ nodeID: NodeID) {
        root.remove(nodeID)
        nodeIds.remove(nodeID)
        // self.nodeLookup.removeValue(forKey: nodeID)
    }

    public func removeAll() {
        root.removeAll()
        nodeIds = []
    }

    public var centroid : Vector2f? {
        get {
            return root.centroid
        }
    }

    static public func create(startingWith node: NodeID, at point: Vector2f, clusterDistance: Float = 1e-6) -> QuadTree<NodeID> {
        let tree = QuadTree<NodeID>(
            quad: Quad.cover(point),
            clusterDistance: clusterDistance
        )
        tree.add(node, at: point)
        return tree
    }
}



extension QuadTreeNode.Children {
    
        public subscript(at quadrant: Quadrant) -> QuadTreeNode<NodeID> {
            get {
                switch quadrant {
                case .northWest:
                    return northWest
                case .northEast:
                    return northEast
                case .southWest:
                    return southWest
                case .southEast:
                    return southEast
                }
            }
            set {
                switch quadrant {
                case .northWest:
                    northWest = newValue
                case .northEast:
                    northEast = newValue
                case .southWest:
                    southWest = newValue
                case .southEast:
                    southEast = newValue
                }
            }
        }
    
    public func forEach(_ body: @escaping (QuadTreeNode<NodeID>, Quadrant) -> Void) {
        body(northWest, .northWest)
        body(northEast, .northEast)
        body(southWest, .southWest)
        body(southEast, .southEast)
    }

    public func forEachMutating(_ body: @escaping (inout QuadTreeNode<NodeID>, Quadrant) -> Void) {
        body(&northWest, .northWest)
        body(&northEast, .northEast)
        body(&southWest, .southWest)
        body(&southEast, .southEast)
    }

    @discardableResult
    public func anyMutating(_ predicate: @escaping (inout QuadTreeNode<NodeID>, Quadrant) -> Bool) -> Bool {
        return predicate(&northWest, .northWest)
            || predicate(&northEast, .northEast)
            || predicate(&southWest, .southWest)
            || predicate(&southEast, .southEast)
    }

    public func any(_ predicate: @escaping (QuadTreeNode<NodeID>, Quadrant) -> Bool) -> Bool {
        return predicate(northWest, .northWest)
            || predicate(northEast, .northEast)
            || predicate(southWest, .southWest)
            || predicate(southEast, .southEast)
    }
}









extension QuadTreeNode: CustomDebugStringConvertible {
    internal func getDebugDescription(with indentLevel: Int = 0) -> String {
        let indent = String(repeating: "\t", count: indentLevel)

        guard let children = self.children else {
            return "\(indent)<leaf> \(nodes.count > 0 ? "\(nodes.count) nodes" : "       ") \(quad.debugDescription)\n"
        }
        var childrenDescription = "\(indent)<internal>        \(quad.debugDescription)\n"
        for q in Quadrant.allValues {
            let child = children[at: q]
            childrenDescription += "\(child.getDebugDescription(with: indentLevel + 1))"
        }
        return childrenDescription
    }
    
    public var debugDescription: String {
        return getDebugDescription()
    }
}




extension QuadTree: CustomDebugStringConvertible {
    public var debugDescription: String {
        return root.debugDescription
    }
}
