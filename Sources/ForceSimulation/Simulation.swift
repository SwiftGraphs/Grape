
import WithSpecializedGeneric
import simd

public enum Simulation {}

extension Simulation {

    /// An N-Dimensional force simulation.
    @WithSpecializedGenerics(
        """
        typealias Double2D<NodeID> = _Base<NodeID, simd_double2>
        typealias Double3D<NodeID> = _Base<NodeID, simd_double3>
        typealias Float2D<NodeID> = _Base<NodeID, simd_float2>
        typealias Float3D<NodeID> = _Base<NodeID, simd_float3>
        """)
    public final class _Base<NodeID, V>
    where NodeID: Hashable, V: VectorLike, V.Scalar: SimulatableFloatingPoint {

        /// The type of the vector used in the simulation.
        /// Usually this is `Scalar` if you are on Apple platforms.
        public typealias Scalar = V.Scalar

        public let initializedAlpha: Scalar

        public var alpha: Scalar
        public var alphaMin: Scalar
        public var alphaDecay: Scalar
        public var alphaTarget: Scalar

        public var velocityDecay: Scalar

        public internal(set) var forces: [any ForceLike] = []

        /// The position of points stored in simulation.
        /// Ordered as the nodeIds you passed in when initializing simulation.
        /// They are always updated.
        public internal(set) var nodePositions: [V]

        /// The velocities of points stored in simulation.
        /// Ordered as the nodeIds you passed in when initializing simulation.
        /// They are always updated.
        public internal(set) var nodeVelocities: [V]

        /// The fixed positions of points stored in simulation.
        /// Ordered as the nodeIds you passed in when initializing simulation.
        /// They are always updated.
        public internal(set) var nodeFixations: [V?]

        public private(set) var nodeIds: [NodeID]

        @usableFromInline internal private(set) var nodeIdToIndexLookup: [NodeID: Int] = [:]

        /// Create a new simulation.
        /// - Parameters:
        ///   - nodeIds: Hashable identifiers for the nodes. Force simulation calculate them by order once created.
        ///   - alpha:
        ///   - alphaMin:
        ///   - alphaDecay: The larger the value, the faster the simulation converges to the final result.
        ///   - alphaTarget:
        ///   - velocityDecay:
        ///   - getInitialPosition: The closure to set the initial position of the node. If not provided, the initial position is set to zero.
        public init(
            nodeIds: [NodeID],
            alpha: Scalar = 1,
            alphaMin: Scalar = 1e-3,
            alphaDecay: Scalar = 2e-3,
            alphaTarget: Scalar = 0.0,
            velocityDecay: Scalar = 0.6,

            setInitialStatus getInitialPosition: (
                (NodeID) -> V
            )? = nil

        ) {

            self.alpha = alpha
            self.initializedAlpha = alpha  // record and reload this when restarted

            self.alphaMin = alphaMin
            self.alphaDecay = alphaDecay
            self.alphaTarget = alphaTarget

            self.velocityDecay = velocityDecay

            if let getInitialPosition {
                self.nodePositions = nodeIds.map(getInitialPosition)
            } else {
                self.nodePositions = Array(repeating: .zero, count: nodeIds.count)
            }

            self.nodeVelocities = Array(repeating: .zero, count: nodeIds.count)
            self.nodeFixations = Array(repeating: nil, count: nodeIds.count)

            self.nodeIdToIndexLookup.reserveCapacity(nodeIds.count)
            for i in nodeIds.indices {
                self.nodeIdToIndexLookup[nodeIds[i]] = i
            }
            self.nodeIds = nodeIds

        }

        /// Get the index in the nodeArray for `nodeId`
        /// - **Complexity**: O(1)
        public func getIndex(of nodeId: NodeID) -> Int {
            return nodeIdToIndexLookup[nodeId]!
        }

        /// Reset the alpha. The points will move faster as alpha gets larger.
        public func resetAlpha(_ alpha: Scalar) {
            self.alpha = alpha
        }

        /// Run the simulation for a number of iterations.
        /// Goes through all the forces created.
        /// The forces will call  `apply` then the positions and velocities will be modified.
        /// - Parameter iterationCount: Default to 1.
        public func tick(iterationCount: UInt = 1) {
            for _ in 0..<iterationCount {
                alpha += (alphaTarget - alpha) * alphaDecay

                for f in forces {
                    f.apply()
                }

                for i in nodePositions.indices {
                    if let fixation = nodeFixations[i] {
                        nodePositions[i] = fixation
                    } else {
                        nodeVelocities[i] *= velocityDecay
                        nodePositions[i] += nodeVelocities[i]
                    }
                }

            }
        }

        /// # Utils for creating forces

        /// Create a center force that drives nodes towards the center.
        /// Center force is relatively fast, the complexity is `O(n)`,
        /// where `n` is the number of nodes.
        /// See [Collide Force - D3](https://d3js.org/d3-force/collide).
        /// - Parameters:
        ///  - center: The center of the force.
        ///  - strength: The strength of the force.
        @discardableResult
        public func createCenterForce(center: V, strength: V.Scalar = 0.1) -> CenterForce {
            let f = CenterForce(center: center, strength: strength)
            f.simulation = self
            self.forces.append(f)
            return f
        }

        /// Create a collide force that prevents nodes from overlapping.
        /// This is a very expensive force, the complexity is `O(n log(n))`,
        /// where `n` is the number of nodes.
        /// See [Collide Force - D3](https://d3js.org/d3-force/collide).
        /// - Parameters:
        ///   - radius: The radius of the force.
        ///   - strength: The strength of the force.
        ///   - iterationsPerTick: The number of iterations per tick.
        @discardableResult
        public func createCollideForce(
            radius: CollideForce.CollideRadius = .constant(3.0),
            strength: V.Scalar = 1.0,
            iterationsPerTick: UInt = 1
        ) -> CollideForce {
            let f = CollideForce(
                radius: radius,
                strength: strength,
                iterationsPerTick: iterationsPerTick
            )
            f.simulation = self
            self.forces.append(f)
            return f
        }

        @discardableResult
        public func createManyBodyForce(
            strength: V.Scalar,
            nodeMass: ManyBodyForce.NodeMass = .constant(1.0)
        ) -> ManyBodyForce {
            let manyBodyForce = ManyBodyForce(
                strength: strength, nodeMass: nodeMass)
            manyBodyForce.simulation = self
            self.forces.append(manyBodyForce)
            return manyBodyForce
        }

        /// Create a link force that represents links between nodes. It works like
        /// there is a spring between each pair of nodes.
        /// The complexity is `O(e)`, where `e` is the number of links.
        /// See [Collide Force - D3](https://d3js.org/d3-force/collide)
        /// - Parameters:
        ///  - links: The links between nodes.
        ///  - stiffness: The stiffness of the spring (or links).
        ///  - originalLength: The original length of the spring (or links).
        @discardableResult
        public func createLinkForce(
            _ links: [EdgeID<NodeID>],
            stiffness: LinkForce.LinkStiffness = .weightedByDegree { _, _ in 1.0 },
            originalLength: LinkForce.LinkLength = .constant(30.0),
            iterationsPerTick: UInt = 1
        ) -> LinkForce {
            let linkForce = LinkForce(
                links, stiffness: stiffness, originalLength: originalLength)
            linkForce.simulation = self
            self.forces.append(linkForce)
            return linkForce
        }

        /// Create a link force that represents links between nodes. It works like
        /// there is a spring between each pair of nodes.
        /// The complexity is `O(e)`, where `e` is the number of links.
        /// See [Link Force - D3](https://d3js.org/d3-force/link).
        /// - Parameters:
        ///  - links: The links between nodes.
        ///  - stiffness: The stiffness of the spring (or links).
        ///  - originalLength: The original length of the spring (or links).
        @discardableResult
        public func createLinkForce(
            _ linkTuples: [(NodeID, NodeID)],
            stiffness: LinkForce.LinkStiffness = .weightedByDegree { _, _ in 1.0 },
            originalLength: LinkForce.LinkLength = .constant(30.0),
            iterationsPerTick: UInt = 1
        ) -> LinkForce {
            let links = linkTuples.map { EdgeID($0.0, $0.1) }
            let linkForce = LinkForce(
                links, stiffness: stiffness, originalLength: originalLength)
            linkForce.simulation = self
            self.forces.append(linkForce)
            return linkForce
        }

        final public class CenterForce: ForceLike {

            public var center: V
            public var strength: V.Scalar
            weak var simulation: _Base<NodeID, V>?

            internal init(center: V, strength: V.Scalar) {
                self.center = center
                self.strength = strength
            }

            public func apply() {
                guard let sim = self.simulation else { return }
                var meanPosition = V.zero
                for n in sim.nodePositions {
                    meanPosition += n  //.position
                }
                let delta = meanPosition * (self.strength / V.Scalar(sim.nodePositions.count))

                for i in sim.nodePositions.indices {
                    sim.nodePositions[i] -= delta
                }
            }

        }

        /// A force that prevents nodes from overlapping.
        /// This is a very expensive force, the complexity is `O(n log(n))`,
        /// where `n` is the number of nodes.
        /// See [Collide Force - D3](https://d3js.org/d3-force/collide).
        public final class CollideForce: ForceLike {

            weak var simulation: _Base<NodeID, V>? {
                didSet {
                    guard let sim = simulation else { return }
                    self.calculatedRadius = radius.calculated(for: sim)
                }
            }

            public enum CollideRadius {
                case constant(V.Scalar)
                case varied((NodeID) -> V.Scalar)

                public func calculated(for simulation: _Base<NodeID, V>) -> [V.Scalar] {
                    switch self {
                    case .constant(let r):
                        return Array(repeating: r, count: simulation.nodePositions.count)
                    case .varied(let radiusProvider):
                        return simulation.nodeIds.map { radiusProvider($0) }
                    }
                }
            }
            public var radius: CollideRadius
            var calculatedRadius: [V.Scalar] = []

            public let iterationsPerTick: UInt
            public var strength: V.Scalar

            internal init(
                radius: CollideRadius,
                strength: V.Scalar = 1.0,
                iterationsPerTick: UInt = 1
            ) {
                self.radius = radius
                self.iterationsPerTick = iterationsPerTick
                self.strength = strength
            }

            public func apply() {
                guard let sim = self.simulation else { return }
                //                let alpha = sim.alpha

                for _ in 0..<iterationsPerTick {

                    let coveringBox = NDBox<V>.cover(of: sim.nodePositions)

                    let clusterDistance: V.Scalar = V.Scalar(Int(0.00001))

                    let tree = #ReplaceWhenSpecializing(
                        NDTree<V, MaxRadiusTreeDelegate<Int, V>>(
                            box: coveringBox, clusterDistance: clusterDistance
                        ) {
                            return switch self.radius {
                            case .constant(let m):
                                MaxRadiusTreeDelegate<Int, V> { _ in m }
                            case .varied(_):
                                MaxRadiusTreeDelegate<Int, V> { index in
                                    self.calculatedRadius[index]
                                }
                            }
                        },
                        lookupOn: [
                            "Double2D": """
                                Quadtree<MaxRadiusTreeDelegate2D<Int>>(
                                    box: coveringBox, clusterDistance: clusterDistance
                                ) {
                                    return switch self.radius {
                                    case .constant(let m):
                                        MaxRadiusTreeDelegate2D<Int> { _ in m }
                                    case .varied(_):
                                        MaxRadiusTreeDelegate2D<Int> { index in
                                            self.calculatedRadius[index]
                                        }
                                    }
                                }
                                """
                                ], 
                        fallback: """
                        NDTree<V, MaxRadiusTreeDelegate<Int, V>>(
                            box: coveringBox, clusterDistance: clusterDistance
                        ) {
                            return switch self.radius {
                            case .constant(let m):
                                MaxRadiusTreeDelegate<Int, V> { _ in m }
                            case .varied(_):
                                MaxRadiusTreeDelegate<Int, V> { index in
                                    self.calculatedRadius[index]
                                }
                            }
                        }
                        """)

                    for i in sim.nodePositions.indices {
                        tree.add(i, at: sim.nodePositions[i])
                    }

                    for i in sim.nodePositions.indices {
                        let iOriginalPosition = sim.nodePositions[i]
                        let iOriginalVelocity = sim.nodeVelocities[i]
                        let iR = self.calculatedRadius[i]
                        let iR2 = iR * iR
                        let iPosition = iOriginalPosition + iOriginalVelocity

                        tree.visit { t in

                            let maxRadiusOfQuad = t.delegate.maxNodeRadius
                            let deltaR = maxRadiusOfQuad + iR

                            if t.nodePosition != nil {
                                for j in t.nodeIndices {
                                    //                            print("\(i)<=>\(j)")
                                    // is leaf, make sure every collision happens once.
                                    guard j > i else { continue }

                                    let jR = self.calculatedRadius[j]
                                    let jOriginalPosition = sim.nodePositions[j]
                                    let jOriginalVelocity = sim.nodeVelocities[j]
                                    var deltaPosition =
                                        iPosition - (jOriginalPosition + jOriginalVelocity)
                                    let l = deltaPosition.lengthSquared()

                                    let deltaR = iR + jR
                                    if l < deltaR * deltaR {

                                        var l = deltaPosition.jiggled().length()
                                        l = (deltaR - l) / l * self.strength

                                        let jR2 = jR * jR

                                        let k = jR2 / (iR2 + jR2)

                                        deltaPosition *= l

                                        sim.nodeVelocities[i] += deltaPosition * k
                                        sim.nodeVelocities[j] -= deltaPosition * (1 - k)
                                    }
                                }
                                return false
                            }

                            for laneIndex in t.box.p0.indices {
                                let _v = t.box.p0[laneIndex]
                                if _v > iPosition[laneIndex] + deltaR /* True if no overlap */ {
                                    return false
                                }
                            }

                            for laneIndex in t.box.p1.indices {
                                let _v = t.box.p1[laneIndex]
                                if _v < iPosition[laneIndex] - deltaR /* True if no overlap */ {
                                    return false
                                }
                            }
                            return true

                            // return
                            //     !(t.quad.x0 > iPosition.x + deltaR /* True if no overlap */
                            //     || t.quad.x1 < iPosition.x - deltaR
                            //     || t.quad.y0 > iPosition.y + deltaR
                            //     || t.quad.y1 < iPosition.y - deltaR)
                        }
                    }
                }
            }

        }

        final public class ManyBodyForce: ForceLike {

            var strength: V.Scalar

            public enum NodeMass {
                case constant(V.Scalar)
                case varied((NodeID) -> V.Scalar)

                public func calculated(for simulation: _Base<NodeID, V>) -> [V.Scalar] {
                    switch self {
                    case .constant(let m):
                        return Array(repeating: m, count: simulation.nodePositions.count)
                    case .varied(let massGetter):
                        return simulation.nodeIds.map { n in
                            return massGetter(n)
                        }
                    }
                }
            }
            var mass: NodeMass
            var precalculatedMass: [V.Scalar] = []

            weak var simulation: _Base<NodeID, V>? {
                didSet {
                    guard let sim = self.simulation else { return }
                    self.precalculatedMass = self.mass.calculated(for: sim)
                    self.forces = [V](repeating: .zero, count: sim.nodePositions.count)
                }
            }

            var theta2: V.Scalar
            var theta: V.Scalar {
                didSet {
                    theta2 = theta * theta
                }
            }

            var distanceMin2: V.Scalar = 1
            var distanceMax2: V.Scalar = V.Scalar.infinity
            var distanceMin: V.Scalar = 1
            var distanceMax: V.Scalar = V.Scalar.infinity

            internal init(
                strength: V.Scalar,
                nodeMass: NodeMass = .constant(1.0),
                theta: V.Scalar = 0.9
            ) {
                self.strength = strength
                self.mass = nodeMass
                self.theta = theta
                self.theta2 = theta * theta
            }

            var forces: [V] = []
            public func apply() {
                guard let simulation else { return }

                let alpha = simulation.alpha

                try! calculateForce(alpha: alpha)  //else { return }

                for i in simulation.nodeVelocities.indices {
                    simulation.nodeVelocities[i] += self.forces[i] / precalculatedMass[i]
                }
            }

            func calculateForce(alpha: V.Scalar) throws {

                guard let sim = self.simulation else {
                    throw ManyBodyForceError.buildQuadTreeBeforeSimulationInitialized
                }

                let coveringBox = NDBox<V>.cover(of: sim.nodePositions)  //try! getCoveringBox()

                let tree = #ReplaceWhenSpecializing(
                    NDTree<V, MassQuadtreeDelegate<Int, V>>(
                    box: coveringBox, clusterDistance: 1e-5
                ) {

                    return switch self.mass {
                    case .constant(let m):
                        MassQuadtreeDelegate<Int, V> { _ in m }
                    case .varied(_):
                        MassQuadtreeDelegate<Int, V> { index in
                            self.precalculatedMass[index]
                        }
                    }
                }, lookupOn: [
                    "Double2D": """
                    Quadtree<MassQuadtreeDelegate2D<Int>>(
                    box: coveringBox, clusterDistance: 1e-5
                ) {

                    return switch self.mass {
                    case .constant(let m):
                        MassQuadtreeDelegate2D<Int> { _ in m }
                    case .varied(_):
                        MassQuadtreeDelegate2D<Int> { index in
                            self.precalculatedMass[index]
                        }
                    }
                }
                """
                ], fallback: """
                            NDTree<V, MassQuadtreeDelegate<Int, V>>(
                    box: coveringBox, clusterDistance: 1e-5
                ) {

                    return switch self.mass {
                    case .constant(let m):
                        MassQuadtreeDelegate<Int, V> { _ in m }
                    case .varied(_):
                        MassQuadtreeDelegate<Int, V> { index in
                            self.precalculatedMass[index]
                        }
                    }
                }
                """)

                for i in sim.nodePositions.indices {
                    tree.add(i, at: sim.nodePositions[i])

                    assert(tree.delegate.accumulatedCount == i + 1)

                }

                for i in sim.nodePositions.indices {
                    var f = V.zero
                    tree.visit { t in

                        guard t.delegate.accumulatedCount > 0 else { return false }
                        let centroid =
                            t.delegate.accumulatedMassWeightedPositions / t.delegate.accumulatedMass

                        let vec = centroid - sim.nodePositions[i]
                        let boxWidth = (t.box.p1 - t.box.p0)[0]
                        var distanceSquared = vec.jiggled().lengthSquared()

                        let farEnough: Bool =
                            (distanceSquared * self.theta2) > (boxWidth * boxWidth)

                        //                let distance = distanceSquared.squareRoot()

                        if distanceSquared < self.distanceMin2 {
                            distanceSquared = (self.distanceMin2 * distanceSquared).squareRoot()
                        }

                        if farEnough {

                            guard distanceSquared < self.distanceMax2 else { return true }

                            /// Workaround for "The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions"
                            let k: V.Scalar =
                                self.strength * alpha * t.delegate.accumulatedMass
                                / distanceSquared  // distanceSquared.squareRoot()

                            f += vec * k
                            return false

                        } else if t.children != nil {
                            return true
                        }

                        if t.isFilledLeaf {

                            if t.nodeIndices.contains(i) { return false }

                            let massAcc = t.delegate.accumulatedMass
                            //                    t.nodeIndices.contains(i) ?  (t.delegate.accumulatedMass-self.precalculatedMass[i]) : (t.delegate.accumulatedMass)
                            let k: V.Scalar = self.strength * alpha * massAcc / distanceSquared  // distanceSquared.squareRoot()
                            f += vec * k
                            return false
                        } else {
                            return true
                        }
                    }
                    forces[i] = f
                }

            }

        }

        final public class LinkForce: ForceLike {

            ///
            public enum LinkStiffness {
                case constant(V.Scalar)
                case varied((EdgeID<NodeID>, LinkLookup<NodeID>) -> V.Scalar)
                case weightedByDegree(k: (EdgeID<NodeID>, LinkLookup<NodeID>) -> V.Scalar)

                func calculated(
                    for links: [EdgeID<NodeID>],
                    connectionLookupTable lookup: LinkLookup<NodeID>
                ) -> [V.Scalar] {
                    switch self {
                    case .constant(let value):
                        return links.map { _ in value }
                    case .varied(let f):
                        return links.map { link in
                            f(link, lookup)
                        }
                    case .weightedByDegree(let k):
                        return links.map { link in
                            k(link, lookup)
                                / V.Scalar(
                                    min(
                                        lookup.count[link.source, default: 0],
                                        lookup.count[link.target, default: 0]
                                    )
                                )
                        }
                    }
                }
            }
            var linkStiffness: LinkStiffness
            var calculatedStiffness: [V.Scalar] = []

            ///
            public typealias LengthScalar = V.Scalar
            public enum LinkLength {
                case constant(LengthScalar)
                case varied((EdgeID<NodeID>, LinkLookup<NodeID>) -> LengthScalar)

                func calculated(
                    for links: [EdgeID<NodeID>],
                    connectionLookupTable: LinkLookup<NodeID>
                ) -> [V.Scalar] {
                    switch self {
                    case .constant(let value):
                        return links.map { _ in value }
                    case .varied(let f):
                        return links.map { link in
                            f(link, connectionLookupTable)
                        }
                    }
                }
            }
            var linkLength: LinkLength
            var calculatedLength: [LengthScalar] = []

            /// Bias
            var calculatedBias: [V.Scalar] = []

            /// Binding to simulation
            ///
            weak var simulation: _Base<NodeID, V>? {
                didSet {

                    guard let sim = simulation else { return }

                    linksOfIndices = links.map { l in
                        EdgeID(
                            sim.nodeIdToIndexLookup[l.source, default: 0],
                            sim.nodeIdToIndexLookup[l.target, default: 0]
                        )
                    }

                    self.lookup = .buildFromLinks(linksOfIndices)

                    self.calculatedBias = linksOfIndices.map { l in
                        V.Scalar(lookup.count[l.source, default: 0])
                            / V.Scalar(
                                lookup.count[l.target, default: 0]
                                    + lookup.count[l.source, default: 0])
                    }

                    let lookupWithOriginalID = LinkLookup.buildFromLinks(links)
                    self.calculatedLength = linkLength.calculated(
                        for: self.links, connectionLookupTable: lookupWithOriginalID)
                    self.calculatedStiffness = linkStiffness.calculated(
                        for: self.links, connectionLookupTable: lookupWithOriginalID)
                }
            }

            var iterationsPerTick: UInt

            internal var linksOfIndices: [EdgeID<Int>] = []
            var links: [EdgeID<NodeID>]

            public struct LinkLookup<_NodeID> where _NodeID: Hashable {
                let sources: [_NodeID: [_NodeID]]
                let targets: [_NodeID: [_NodeID]]
                let count: [_NodeID: Int]

                static func buildFromLinks(_ links: [EdgeID<_NodeID>]) -> Self {
                    var sources: [_NodeID: [_NodeID]] = [:]
                    var targets: [_NodeID: [_NodeID]] = [:]
                    var count: [_NodeID: Int] = [:]
                    for link in links {
                        sources[link.source, default: []].append(link.target)
                        targets[link.target, default: []].append(link.source)
                        count[link.source, default: 0] += 1
                        count[link.target, default: 0] += 1
                    }
                    return Self(sources: sources, targets: targets, count: count)
                }
            }
            private var lookup = LinkLookup<Int>(sources: [:], targets: [:], count: [:])

            internal init(
                _ links: [EdgeID<NodeID>],
                stiffness: LinkStiffness,
                originalLength: LinkLength = .constant(30),
                iterationsPerTick: UInt = 1
            ) {
                self.links = links
                self.iterationsPerTick = iterationsPerTick
                self.linkStiffness = stiffness
                self.linkLength = originalLength

            }

            public func apply() {
                guard let sim = self.simulation else { return }

                let alpha = sim.alpha

                for _ in 0..<iterationsPerTick {
                    for i in links.indices {

                        let s = linksOfIndices[i].source
                        let t = linksOfIndices[i].target

                        let _source = sim.nodePositions[s]
                        let _target = sim.nodePositions[t]

                        let b = self.calculatedBias[i]

                        #if DEBUG
                            assert(b != 0)
                        #endif

                        var vec =
                            (_target + sim.nodeVelocities[t] - _source - sim.nodeVelocities[s])
                            .jiggled()

                        var l = vec.length()

                        l = (l - self.calculatedLength[i]) / l * alpha * self.calculatedStiffness[i]

                        vec *= l

                        // same as d3
                        sim.nodeVelocities[t] -= vec * b
                        sim.nodeVelocities[s] += vec * (1 - b)

                        //                sim.nodeVelocities[s] += vec * b
                        //                sim.nodeVelocities[t] -= vec * (1 - b)

                    }
                }
            }

        }

    }

}
