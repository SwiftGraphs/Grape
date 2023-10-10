// The Swift Programming Language
// https://docs.swift.org/swift-book

// #if arch(wasm32)
// import SimdPolyfill
// #else
import simd

// #endif

// TODO: https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwjoh_vKttuBAxUunokEHdchDZAQFnoECBkQAQ&url=https%3A%2F%2Fosf.io%2Fdu6gq%2Fdownload%2F%3Fversion%3D1%26displayName%3Dgove-2018-updating-tree-approximations-2018-06-13T02%253A16%253A17.463Z.pdf&usg=AOvVaw3KFAE5U8cnhTDMN_qrzV6a&opi=89978449
public class QuadTreeNode2<N, QD> where N: Identifiable, QD: QuadDelegate, QD.Node == N {

    public private(set) var quad: Quad

    public var nodes: [N.ID: Vector2f] = [:]  // TODO: merge nodes if close enough

    final public class Children {
        public private(set) var northWest: QuadTreeNode2<N, QD>
        public private(set) var northEast: QuadTreeNode2<N, QD>
        public private(set) var southWest: QuadTreeNode2<N, QD>
        public private(set) var southEast: QuadTreeNode2<N, QD>
        internal init(
            _ northWest: QuadTreeNode2<N, QD>,
            _ northEast: QuadTreeNode2<N, QD>,
            _ southWest: QuadTreeNode2<N, QD>,
            _ southEast: QuadTreeNode2<N, QD>
        ) {
            self.northWest = northWest
            self.northEast = northEast
            self.southWest = southWest
            self.southEast = southEast
        }

    }

    public private(set) var children: Children?

    public let clusterDistance: Float

    public var quadDelegate: QD

    internal init(
        quad: Quad,
        clusterDistance: Float,
        rootQuadDelegate: QD
    ) {
        self.quad = quad
        self.clusterDistance = clusterDistance
        self.quadDelegate = rootQuadDelegate.createNew()
    }

    public func add(_ node: N, at point: Vector2f) {
        cover(point)

        defer {
            quadDelegate.didAddNode(node, at: point)
        }

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
                let divided = QuadTreeNode2.divide(
                    quad: quad, clusterDistance: clusterDistance, rootQuadDelegate: quadDelegate)

                if !nodes.isEmpty {
                    let direction = quad.quadrantOf(nodes.first!.value)
                    divided[at: direction].nodes = self.nodes
                    divided[at: direction].quadDelegate = self.quadDelegate
                    self.quadDelegate = self.quadDelegate.copy()
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

    }

    private func expand(towards quadrant: Quadrant) {
        let nailedQuadrant = quadrant.reversed
        let nailedCorner = quad.getCorner(of: nailedQuadrant)
        let expandedCorner = quad.getCorner(of: quadrant) * 2 - nailedCorner

        let newRootQuad = Quad(corner: nailedCorner, oppositeCorner: expandedCorner)
        let copiedCurrentNode = shallowCopy()
        let divided = QuadTreeNode2.divide(
            quad: newRootQuad, clusterDistance: clusterDistance, rootQuadDelegate: quadDelegate)
        divided[at: nailedQuadrant] = copiedCurrentNode

        self.quad = newRootQuad
        self.children = divided
        self.nodes = [:]
        self.quadDelegate = quadDelegate.copy()
    }

    private static func divide(quad: Quad, clusterDistance: Float, rootQuadDelegate: QD) -> Children
    {
        let divided = quad.divide()
        let northWest = QuadTreeNode2(
            quad: divided.northWest, clusterDistance: clusterDistance,
            rootQuadDelegate: rootQuadDelegate)
        let northEast = QuadTreeNode2(
            quad: divided.northEast, clusterDistance: clusterDistance,
            rootQuadDelegate: rootQuadDelegate)
        let southWest = QuadTreeNode2(
            quad: divided.southWest, clusterDistance: clusterDistance,
            rootQuadDelegate: rootQuadDelegate)
        let southEast = QuadTreeNode2(
            quad: divided.southEast, clusterDistance: clusterDistance,
            rootQuadDelegate: rootQuadDelegate)
        return Children(northWest, northEast, southWest, southEast)
    }

    /**
     *  Copy object while holding the same reference to children
     */
    private func shallowCopy() -> QuadTreeNode2<N, QD> {
        let copy = QuadTreeNode2(
            quad: quad, clusterDistance: clusterDistance, rootQuadDelegate: quadDelegate)
        copy.nodes = nodes
        copy.children = children
        copy.quadDelegate = quadDelegate
        return copy
    }

    public var isLeaf: Bool {
        return children == nil
    }
}

enum QuadTree2Error: Error {
    case noNodeProvidedError
}

final public class QuadTree2<N, QD> where N: Identifiable, QD: QuadDelegate, QD.Node == N {
    public private(set) var root: QuadTreeNode2<N, QD>
    private var nodeIds: Set<N.ID> = []

    public let clusterDistance: Float

    public init(
        quad: Quad,
        clusterDistance: Float = 1e-6,
        getQuadDelegate: @escaping () -> QD
    ) {
        self.clusterDistance = clusterDistance
        self.root = QuadTreeNode2<N, QD>(
            quad: quad,
            clusterDistance: clusterDistance,
            rootQuadDelegate: getQuadDelegate()
        )
    }

    public init(
        nodes: [(N, Vector2f)],
        clusterDistance: Float = 1e-6,
        getQuadDelegate: @escaping () -> QD
    ) throws {
        guard let firstEntry = nodes.first else {
            throw QuadTreeError.noNodeProvidedError
        }
        self.clusterDistance = clusterDistance
        self.root = QuadTreeNode2<N, QD>(
            quad: Quad.cover(firstEntry.1),
            clusterDistance: clusterDistance,
            rootQuadDelegate: getQuadDelegate()
        )
        self.addAll(nodes)
    }

    public func add(_ node: N, at point: Vector2f) {
        root.add(node, at: point)
        nodeIds.insert(node.id)
    }

    public func add(_ node: N, at point: (Float, Float)) {
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

    static public func create(
        startingWith node: N,
        at point: Vector2f,
        clusterDistance: Float = 1e-6,
        getQuadDelegate: @escaping () -> QD
    ) -> QuadTree2<N, QD> where N: Identifiable {
        let tree = QuadTree2<N, QD>(
            quad: Quad.cover(point),
            clusterDistance: clusterDistance,
            getQuadDelegate: getQuadDelegate
        )
        tree.add(node, at: point)
        return tree
    }

    public var quad: Quad { return root.quad }
}

extension QuadTreeNode2.Children {

    public subscript(at quadrant: Quadrant) -> QuadTreeNode2<N, QD> {
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

    public func forEach(_ body: @escaping (QuadTreeNode2<N, QD>, Quadrant) -> Void) {
        body(northWest, .northWest)
        body(northEast, .northEast)
        body(southWest, .southWest)
        body(southEast, .southEast)
    }

    public func forEachMutating(_ body: @escaping (inout QuadTreeNode2<N, QD>, Quadrant) -> Void) {
        body(&northWest, .northWest)
        body(&northEast, .northEast)
        body(&southWest, .southWest)
        body(&southEast, .southEast)
    }

    @discardableResult
    public func anyMutating(_ predicate: @escaping (inout QuadTreeNode2<N, QD>, Quadrant) -> Bool)
        -> Bool
    {
        return predicate(&northWest, .northWest)
            || predicate(&northEast, .northEast)
            || predicate(&southWest, .southWest)
            || predicate(&southEast, .southEast)
    }

    public func any(_ predicate: @escaping (QuadTreeNode2<N, QD>, Quadrant) -> Bool) -> Bool {
        return predicate(northWest, .northWest)
            || predicate(northEast, .northEast)
            || predicate(southWest, .southWest)
            || predicate(southEast, .southEast)
    }
}

public protocol QuadDelegate {
    associatedtype Node
    mutating func didAddNode(_ node: Node, at position: Vector2f)
    mutating func didRemoveNode(_ node: Node, at position: Vector2f)
    func copy() -> Self
    func createNew() -> Self
}

extension QuadTreeNode2 {

    public func visitAfter<T>(
        _ action: @escaping (
            T, QuadTreeNode2<N, QD>
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
            QuadTreeNode2<N, QD>
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
            QuadTreeNode2<N, QD>
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

extension QuadTree2 {

    @available(*, deprecated)
    @discardableResult
    public func visitAfter<T>(
        withResult action: @escaping (
            T, QuadTreeNode2<N, QD>
        ) -> T
    ) -> T where T: AdditiveArithmetic {
        return root.visitAfter(action)
    }

    @available(*, deprecated)
    public func visitAfter(
        _ action: @escaping (
            QuadTreeNode2<N, QD>
        ) -> Void
    ) {
        return root.visitAfter(action)
    }

    public func visit(
        _ decideWhetherToVisitChildrenAfterAction: @escaping (
            QuadTreeNode2<N, QD>
        ) -> Bool
    ) {
        root.visit(decideWhetherToVisitChildrenAfterAction)
    }
}
