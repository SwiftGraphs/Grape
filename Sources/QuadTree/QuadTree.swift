// The Swift Programming Language
// https://docs.swift.org/swift-book

// #if arch(wasm32)
// import SimdPolyfill
// #else
import simd

// #endif

// TODO: https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwjoh_vKttuBAxUunokEHdchDZAQFnoECBkQAQ&url=https%3A%2F%2Fosf.io%2Fdu6gq%2Fdownload%2F%3Fversion%3D1%26displayName%3Dgove-2018-updating-tree-approximations-2018-06-13T02%253A16%253A17.463Z.pdf&usg=AOvVaw3KFAE5U8cnhTDMN_qrzV6a&opi=89978449
@available(*, deprecated)
public class QuadTreeNode<N> where N: Identifiable, N: HasMassLikeProperty {

    public private(set) var quad: Quad

    public var nodes: [N.ID: Vector2f] = [:]  // TODO: merge nodes if close enough

    public var accumulatedProperty: Double = 0.0
    public var accumulatedCount = 0
    public var weightedAccumulatedNodePositions: Vector2f = .zero
    public var centroid: Vector2f? {
        if accumulatedCount == 0 {
            return nil
        }
        return weightedAccumulatedNodePositions / accumulatedProperty
    }

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

    public let clusterDistance: Double

    internal init(
        quad: Quad,
        clusterDistance: Double
    ) {
        self.quad = quad
        self.clusterDistance = clusterDistance
        //        self.value = .zero
    }

    public func add(_ node: N, at point: Vector2f) {
        cover(point)

        accumulatedCount += 1
        accumulatedProperty += node.property
        weightedAccumulatedNodePositions += node.property * point

        guard let children = self.children else {
            if nodes.isEmpty {
                // no children, not occupied => take this point
                nodes[node.id] = point
                return
            } else if nodes.first!.value.distanceTo(point) < clusterDistance {
                // no children, close enough => take this point
                nodes[node.id] = point
                return
            } else {
                // no children, not close enough => divide & add to children
                let divided = QuadTreeNode.divide(quad: quad, clusterDistance: clusterDistance)

                //                self.nodes.forEach { n, p in
                //                    let direction = quad.quadrantOf(p)
                //                    divided[at: direction].add(n, at: p)
                //                }
                //                self.nodes.removeAll()

                if !nodes.isEmpty {
                    let direction = quad.quadrantOf(nodes.first!.value)
                    divided[at: direction].nodes = self.nodes
                }
                self.nodes = [:]

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

    public func addAll(_ nodesAndPoints: [(N, Vector2f)]) {
        for entry in nodesAndPoints {
            add(entry.0, at: entry.1)
        }
    }

    @discardableResult
    public func remove(_ node: N.ID) -> Bool {
        if nodes.removeValue(forKey: node) != nil {
            return true
        } else {
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
        if quad.contains(point) { return }

        repeat {

            /**
             * (0, 0)
             *           |    point: .northEast
             *           |
             *    ---- quad.x0y0 ----
             *           |
             *           |
             *
             */
            let quadrant: Quadrant =
                switch (point.y < quad.y0, point.x < quad.x0) {
                case (false, false): .southEast
                case (false, true): .southWest
                case (true, true): .northWest
                case (true, false): .northEast
                }

            expand(towards: quadrant)

        } while !quad.contains(point)

        //        if quad.contains(point) {
        //            return
        //        }
        //        else {
        //
        //            let quadrant = quad.quadrantOf(point)
        //            let nailedCorner = quad.getCorner(of: quadrant.reversed)
        //            let expandingCorner = quad.getCorner(of: quadrant)
        //
        //            let coveredArea = expandingCorner - nailedCorner
        //            let uncoveredArea = point - nailedCorner
        //
        //            let scaleX = uncoveredArea.x / coveredArea.x
        //            let scaleY = uncoveredArea.y / coveredArea.y
        //
        //#if DEBUG
        //            assert(scaleX > 0 && scaleY > 0)
        //#endif
        //
        //            let expansionTime = Int(ceilf(log2(
        //                max(scaleX, scaleY)
        //            )))
        //
        //            for _ in 0..<expansionTime {
        //                expand(towards: quadrant)
        //            }
        //
        //
        //            // if point is on the right/bottom bottom, do it again
        //            if !self.quad.contains(point) {
        //                expand(towards: quadrant)
        //            }
        //
        //            #if DEBUG
        //            assert(self.quad.contains(point), "Point is not covered after expansion")
        //            #endif
        //        }
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

    private static func divide(quad: Quad, clusterDistance: Double) -> Children {
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
        copy.accumulatedCount = accumulatedCount
        copy.accumulatedProperty = accumulatedProperty
        copy.weightedAccumulatedNodePositions = weightedAccumulatedNodePositions
        return copy
    }

    public var isLeaf: Bool {
        return children == nil
    }

    //    public var centroid: Vector2f? {
    //        get {
    //            if isLeaf {
    //                return nodes.values.sum() / Double(nodes.count)
    //            }
    //            return nil
    //        }
    //    }
}

enum QuadTreeError: Error {
    case noNodeProvidedError
}

@available(*, deprecated)
final public class QuadTree<N: Identifiable> where N: HasMassLikeProperty {
    public private(set) var root: QuadTreeNode<N>
    private var nodeIds: Set<N.ID> = []

    public let clusterDistance: Double

    public init(
        quad: Quad,
        clusterDistance: Double = 1e-6
    ) {
        self.clusterDistance = clusterDistance
        self.root = QuadTreeNode<N>(
            quad: quad,
            clusterDistance: clusterDistance
        )
    }

    public init(
        nodes: [(N, Vector2f)],
        clusterDistance: Double = 1e-6
    ) throws {
        guard let firstEntry = nodes.first else {
            throw QuadTreeError.noNodeProvidedError
        }
        self.clusterDistance = clusterDistance
        self.root = QuadTreeNode<N>(
            quad: Quad.cover(firstEntry.1),
            clusterDistance: clusterDistance
        )
        self.addAll(nodes)
    }

    public func add(_ node: N, at point: Vector2f) {
        root.add(node, at: point)
        nodeIds.insert(node.id)
    }

    public func add(_ node: N, at point: (Double, Double)) {
        root.add(node, at: Vector2f(point.0, point.1))
        nodeIds.insert(node.id)
    }

    public func addAll(_ nodes: [(N, Vector2f)]) {
        for (node, position) in nodes {
            add(node, at: position)
        }
    }

    public func remove(_ nodeID: N.ID) {
        root.remove(nodeID)
        nodeIds.remove(nodeID)
        // self.nodeLookup.removeValue(forKey: nodeID)
    }

    public func removeAll() {
        root.removeAll()
        nodeIds = []
    }

    public var centroid: Vector2f? {
        return root.centroid
    }

    static public func create(
        startingWith node: N, at point: Vector2f, clusterDistance: Double = 1e-6
    ) -> QuadTree<N> where N: Identifiable {
        let tree = QuadTree<N>(
            quad: Quad.cover(point),
            clusterDistance: clusterDistance
        )
        tree.add(node, at: point)
        return tree
    }

    public var quad: Quad { return root.quad }
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
    public func anyMutating(_ predicate: @escaping (inout QuadTreeNode<N>, Quadrant) -> Bool)
        -> Bool
    {
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
            return
                "\(indent)<leaf> \(nodes.count > 0 ? "\(nodes.count) nodes" : "       ") \(quad.debugDescription)\n"
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

extension QuadTreeNode {

    /// only do action on internal and leafs **that has nodes**
    //    public func visitAfter(
    //        _ action: @escaping(
    //            [NodeID: Vector2f],
    //            Quad
    //        )->Void
    //    ) {
    //
    //        if let children {
    //            children.northWest.visitAfter(action)
    //            children.northEast.visitAfter(action)
    //            children.southWest.visitAfter(action)
    //            children.southEast.visitAfter(action)
    //        }
    //        else if !isLeaf {
    //            action(nodes, quad)
    //        }
    //    }

    //    public func visitAfter<T>(
    //        _ action: @escaping(
    //            T, QuadTreeNode<NodeID>
    //        )->T?,
    //        _ transform: (T?,T?,T?,T?) -> T
    //    ) -> T? {
    //
    //        if let children {
    //
    //            let nw = children.northWest.visitAfter(action, transform)
    //            let ne = children.northEast.visitAfter(action, transform)
    //            let sw = children.southWest.visitAfter(action, transform)
    //            let se = children.southEast.visitAfter(action, transform)
    //
    //            return action(transform(nw,ne,sw,se), self)
    //        }
    //        else if !isLeaf {
    //            return action(self)
    //        }
    //        return nil
    //    }
    //

    public func visitAfter<T>(
        _ action: @escaping (
            T, QuadTreeNode<N>
        ) -> T
    ) -> T where T: AdditiveArithmetic {

        if let children {

            let nw = children.northWest.visitAfter(action)
            let ne = children.northEast.visitAfter(action)
            let sw = children.southWest.visitAfter(action)
            let se = children.southEast.visitAfter(action)

            return action(nw + ne + sw + se, self)
        } else if !isLeaf {
            return action(.zero, self)
        }
        return .zero
    }

    public func visit(
        _ decideWhetherToVisitChildrenAfterAction: @escaping (
            QuadTreeNode<N>
        ) -> Bool
    ) {

        if decideWhetherToVisitChildrenAfterAction(self), let children {
            // this is an internal node
            children.northWest.visit(decideWhetherToVisitChildrenAfterAction)
            children.northEast.visit(decideWhetherToVisitChildrenAfterAction)
            children.southWest.visit(decideWhetherToVisitChildrenAfterAction)
            children.southEast.visit(decideWhetherToVisitChildrenAfterAction)
        }
    }

    public func visitAfter(
        _ action: @escaping (
            QuadTreeNode<N>
        ) -> Void
    ) {

        if let children {

            children.northWest.visitAfter(action)
            children.northEast.visitAfter(action)
            children.southWest.visitAfter(action)
            children.southEast.visitAfter(action)

            action(self)
        } else if !isLeaf {
            action(self)
        }
    }

    public func visitAfter(
        onInternal: @escaping (
            Quad
        ) -> Void,
        onFilledLeaf: @escaping (
            [N.ID: Vector2f],
            Quad
        ) -> Void
    ) {

        if let children {
            onInternal(quad)
            children.northWest.visitAfter(onInternal: onInternal, onFilledLeaf: onFilledLeaf)
            children.northEast.visitAfter(onInternal: onInternal, onFilledLeaf: onFilledLeaf)
            children.southWest.visitAfter(onInternal: onInternal, onFilledLeaf: onFilledLeaf)
            children.southEast.visitAfter(onInternal: onInternal, onFilledLeaf: onFilledLeaf)
        } else if !isLeaf {
            onFilledLeaf(nodes, quad)
        }
    }
}

extension QuadTree {

    @discardableResult
    public func visitAfter<T>(
        withResult action: @escaping (
            T, QuadTreeNode<N>
        ) -> T
    ) -> T where T: AdditiveArithmetic {
        return root.visitAfter(action)
    }

    public func visitAfter(
        _ action: @escaping (
            QuadTreeNode<N>
        ) -> Void
    ) {
        return root.visitAfter(action)
    }

    public func visit(
        _ decideWhetherToVisitChildrenAfterAction: @escaping (
            QuadTreeNode<N>
        ) -> Bool
    ) {
        root.visit(decideWhetherToVisitChildrenAfterAction)
    }
}

public protocol HasMassLikeProperty {
    //    associatedtype Property: MassLikeProperty
    var property: Double { get }
    //    static var propertyZero: Property { get }
}
