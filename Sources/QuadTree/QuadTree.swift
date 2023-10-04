// The Swift Programming Language
// https://docs.swift.org/swift-book

// #if arch(wasm32)
// import SimdPolyfill
// #else
import simd
// #endif

/**
    Only keep N.ID
 */
final public class QuadTreeNode<N: Identifiable> {
    
    public private(set) var quad: Quad
    
    public private(set) var nodes: [N.ID: Vector2f] = [:]  // TODO: merge nodes if close enough

    final public class Children {
        public private(set) var northWest: QuadTreeNode<N>
        public private(set) var northEast: QuadTreeNode<N>
        public private(set) var southWest: QuadTreeNode<N>
        public private(set) var southEast: QuadTreeNode<N>
        internal init(
            _ northWest: QuadTreeNode<N>,
            _ northEast: QuadTreeNode<N>,
            _ southWest: QuadTreeNode<N>,
            _ southEast: QuadTreeNode<N>
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
    
    public func add(_ node: N.ID, at point: Vector2f) {
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

    public func traverse(_ body: @escaping (QuadTreeNode<N>) -> Void) {
        body(self)
        children?.forEach { child, _ in
            child.traverse(body)
        }
    }

    public func addAll(_ nodesAndPoints: Dictionary<N.ID, Vector2f>) {
        for (n, p) in nodes {
            add(n, at: p)
        }
    }
    
    @discardableResult
    public func remove(_ node: N.ID) -> Bool {
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
        let northWest = QuadTreeNode<N>(quad: divided.northWest, clusterDistance: clusterDistance)
        let northEast = QuadTreeNode<N>(quad: divided.northEast, clusterDistance: clusterDistance)
        let southWest = QuadTreeNode<N>(quad: divided.southWest, clusterDistance: clusterDistance)
        let southEast = QuadTreeNode<N>(quad: divided.southEast, clusterDistance: clusterDistance)
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
    private func shallowCopy() -> QuadTreeNode<N> {
        let copy = QuadTreeNode<N>(quad: quad, clusterDistance: clusterDistance)
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

final public class QuadTree<N: Identifiable> {
    public private(set) var root: QuadTreeNode<N>
    public private(set) var nodeLookup: Dictionary<N.ID, N>
    public let clusterDistance: Float

    public init(
        quad: Quad,
        clusterDistance: Float = 1e-6
    ) {
        self.clusterDistance = clusterDistance
        self.root = QuadTreeNode<N>(quad: quad, clusterDistance: clusterDistance)
        self.nodeLookup = [:]
    }

    public init(
        nodes: [(N, Vector2f)],
        clusterDistance: Float = 1e-6
    ) throws {
        guard let firstEntry = nodes.first else {
            throw QuadTreeError.noNodeProvidedError
        }
        self.clusterDistance = clusterDistance
        self.root = QuadTreeNode<N>(
            quad: Quad.cover(firstEntry.1),
            clusterDistance: clusterDistance
        )
        self.nodeLookup = [:]
        self.addAll(nodes)
    }

    public func add(_ node: N, at point: Vector2f) {
        root.add(node.id, at: point)
        nodeLookup[node.id] = node
    }

    public func addAll(_ nodesAndPoints: [(N, Vector2f)]) {
        for (n, p) in nodesAndPoints {
            add(n, at: p)
        }
    }

    public func remove(_ nodeID: N.ID) {
        root.remove(nodeID)
        self.nodeLookup.removeValue(forKey: nodeID)
    }

    public func removeAll() {
        self.nodeLookup = [:]
        root.removeAll()
    }

    public var centroid : Vector2f? {
        get {
            return root.centroid
        }
    }

    static public func create(startingWith node: N, at point: Vector2f, clusterDistance: Float = 1e-6) -> QuadTree<N> {
        let tree = QuadTree<N>(
            quad: Quad.cover(point),
            clusterDistance: clusterDistance
        )
        tree.add(node, at: point)
        return tree
    }
}



extension QuadTreeNode.Children {
    
        public subscript(at quadrant: Quadrant) -> QuadTreeNode<N> {
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
    
    public func forEach(_ body: @escaping (QuadTreeNode<N>, Quadrant) -> Void) {
        body(northWest, .northWest)
        body(northEast, .northEast)
        body(southWest, .southWest)
        body(southEast, .southEast)
    }

    public func forEachMutating(_ body: @escaping (inout QuadTreeNode<N>, Quadrant) -> Void) {
        body(&northWest, .northWest)
        body(&northEast, .northEast)
        body(&southWest, .southWest)
        body(&southEast, .southEast)
    }

    @discardableResult
    public func anyMutating(_ predicate: @escaping (inout QuadTreeNode<N>, Quadrant) -> Bool) -> Bool {
        return predicate(&northWest, .northWest)
            || predicate(&northEast, .northEast)
            || predicate(&southWest, .southWest)
            || predicate(&southEast, .southEast)
    }

    public func any(_ predicate: @escaping (QuadTreeNode<N>, Quadrant) -> Bool) -> Bool {
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
