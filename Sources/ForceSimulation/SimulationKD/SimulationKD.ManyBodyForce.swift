//
//  File.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

public enum ManyBodyForceError: Error {
    case buildQuadTreeBeforeSimulationInitialized
}

public struct MassQuadtreeDelegate<NodeID, V>: NDTreeDelegate
where NodeID: Hashable, V: VectorLike {

    public var accumulatedMass: V.Scalar = .zero
    public var accumulatedCount = 0
    public var accumulatedMassWeightedPositions: V = .zero

    @usableFromInline let massProvider: (NodeID) -> V.Scalar

    @inlinable
    init(
        massProvider: @escaping (NodeID) -> V.Scalar
    ) {
        self.massProvider = massProvider
    }
    @inlinable
    internal init(
        initialAccumulatedProperty: V.Scalar,
        initialAccumulatedCount: Int,
        initialWeightedAccumulatedNodePositions: V,
        massProvider: @escaping (NodeID) -> V.Scalar
    ) {
        self.accumulatedMass = initialAccumulatedProperty
        self.accumulatedCount = initialAccumulatedCount
        self.accumulatedMassWeightedPositions = initialWeightedAccumulatedNodePositions
        self.massProvider = massProvider
    }

    @inlinable mutating public func didAddNode(_ node: NodeID, at position: V) {
        let p = massProvider(node)
        #if DEBUG
            assert(p > 0)
        #endif
        accumulatedCount += 1
        accumulatedMass += p
        accumulatedMassWeightedPositions += position * p
    }

    @inlinable mutating public func didRemoveNode(_ node: NodeID, at position: V) {
        let p = massProvider(node)
        accumulatedCount -= 1
        accumulatedMass -= p
        accumulatedMassWeightedPositions -= position * p
        // TODO: parent removal?
    }

    @inlinable public func copy() -> Self {
        return Self(
            initialAccumulatedProperty: self.accumulatedMass,
            initialAccumulatedCount: self.accumulatedCount,
            initialWeightedAccumulatedNodePositions: self.accumulatedMassWeightedPositions,
            massProvider: self.massProvider
        )
    }

    @inlinable public func spawn() -> Self {
        return Self(massProvider: self.massProvider)
    }

    @inlinable var centroid: V? {
        guard accumulatedCount > 0 else { return nil }
        return accumulatedMassWeightedPositions / accumulatedMass
    }
}

extension SimulationKD {
    /// A force that simulate the many-body force.
    ///
    /// This is a very expensive force, the complexity is `O(n log(n))`,
    /// where `n` is the number of nodes. The complexity might degrade to `O(n^2)` if the nodes are too close to each other.
    /// See [Manybody Force - D3](https://d3js.org/d3-force/many-body).
    final public class ManyBodyForce: ForceLike
    where NodeID: Hashable, V: VectorLike, V.Scalar: SimulatableFloatingPoint {

        @usableFromInline var strength: V.Scalar

        public enum NodeMass {
            case constant(V.Scalar)
            case varied((NodeID) -> V.Scalar)
        }
        @usableFromInline var mass: NodeMass
        @usableFromInline var precalculatedMass: [V.Scalar] = []

        @usableFromInline
        weak var simulation: SimulationKD<NodeID, V>? {
            didSet {
                guard let sim = self.simulation else { return }
                self.precalculatedMass = self.mass.calculated(for: sim)
                self.forces = [V](repeating: .zero, count: sim.nodePositions.count)
            }
        }

        @usableFromInline
        var theta2: V.Scalar

        @usableFromInline
        var theta: V.Scalar {
            didSet {
                theta2 = theta * theta
            }
        }

        @usableFromInline
        var distanceMin2: V.Scalar = 1
        @usableFromInline
        var distanceMax2: V.Scalar = V.Scalar.infinity
        @usableFromInline
        var distanceMin: V.Scalar = 1
        @usableFromInline
        var distanceMax: V.Scalar = V.Scalar.infinity

        @inlinable
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

        @usableFromInline
        var forces: [V] = []

        @inlinable
        public func apply() {
            guard let simulation else { return }

            let alpha = simulation.alpha

            try! calculateForce(alpha: alpha)  //else { return }

            for i in simulation.nodeVelocities.indices {
                simulation.nodeVelocities[i] += self.forces[i] / precalculatedMass[i]
            }
        }

        //    private func getCoveringBox() throws -> NDBox<V> {
        //        guard let simulation else { throw ManyBodyForceError.buildQuadTreeBeforeSimulationInitialized }
        //        var _p0 = simulation.nodes[0].position
        //        var _p1 = simulation.nodes[0].position
        //
        //        for p in simulation.nodes {
        //            for i in 0..<V.scalarCount {
        //                if p.position[i] < _p0[i] {
        //                    _p0[i] = p.position[i]
        //                }
        //                if p.position[i] >= _p1[i] {
        //                    _p1[i] = p.position[i] + 1
        //                }
        //            }
        //        }
        //        return NDBox(_p0, _p1)
        //
        //    }

        @inlinable
        public func calculateForce(alpha: V.Scalar) throws {

            guard let sim = self.simulation else {
                throw ManyBodyForceError.buildQuadTreeBeforeSimulationInitialized
            }

            let coveringBox = NDBox<V>.cover(of: sim.nodePositions)  //try! getCoveringBox()

            let tree = NDTree<V, MassQuadtreeDelegate<Int, V>>(
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

            for i in sim.nodePositions.indices {
                tree.add(i, at: sim.nodePositions[i])

                #if DEBUG
                    assert(tree.delegate.accumulatedCount == i + 1)
                #endif

            }

            //        var forces = [V](repeating: .zero, count: sim.nodePositions.count)

            for i in sim.nodePositions.indices {
                var f = V.zero
                tree.visit { t in

                    //                guard t.delegate.accumulatedCount > 0 else { return false }
                    //
                    //                let centroid = t.delegate.accumulatedMassWeightedPositions / t.delegate.accumulatedMass
                    //                let vec = centroid - sim.nodePositions[i]
                    //
                    //                var distanceSquared = vec.jiggled().lengthSquared()
                    //
                    //                /// too far away, omit
                    //                guard distanceSquared < self.distanceMax2 else { return false }
                    //
                    //
                    //
                    //                /// too close, enlarge distance
                    //                if distanceSquared < self.distanceMin2 {
                    //                    distanceSquared = (self.distanceMin2 * distanceSquared).squareRoot()
                    //                }
                    //
                    //
                    //                if t.nodePosition != nil {
                    //
                    //                    /// filled leaf
                    //                    if !t.nodeIndices.contains(i) {
                    //                        let k: V.Scalar = self.strength * alpha * t.delegate.accumulatedMass / distanceSquared / (distanceSquared).squareRoot()
                    //                        forces[i] += vec * k
                    //                    }
                    //
                    //                    return false
                    //
                    //                }
                    //                else if t.children != nil {
                    //
                    //                    let boxWidth = (t.box.p1 - t.box.p1)[0]
                    //
                    //                    /// internal, guard in 180 guarantees we have nodes here
                    //                    if distanceSquared * self.theta2 > boxWidth * boxWidth {
                    //                        // far enough
                    //                        let k: V.Scalar = self.strength * alpha * t.delegate.accumulatedMass / distanceSquared / (distanceSquared).squareRoot()
                    //                        forces[i] += vec * k
                    //                        return false
                    //                    }
                    //                    else {
                    //                        return true
                    //                    }
                    //                }
                    //                else {
                    //                    // empty leaf
                    //                    return false
                    //                }

                    guard t.delegate.accumulatedCount > 0 else { return false }
                    let centroid =
                        t.delegate.accumulatedMassWeightedPositions / t.delegate.accumulatedMass

                    let vec = centroid - sim.nodePositions[i]
                    let boxWidth = (t.box.p1 - t.box.p0)[0]
                    var distanceSquared = vec.jiggled().lengthSquared()

                    let farEnough: Bool = (distanceSquared * self.theta2) > (boxWidth * boxWidth)

                    //                let distance = distanceSquared.squareRoot()

                    if distanceSquared < self.distanceMin2 {
                        distanceSquared = (self.distanceMin2 * distanceSquared).squareRoot()
                    }

                    if farEnough {

                        guard distanceSquared < self.distanceMax2 else { return true }

                        /// Workaround for "The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions"
                        let k: V.Scalar =
                            self.strength * alpha * t.delegate.accumulatedMass / distanceSquared  // distanceSquared.squareRoot()

                        f += vec * k
                        return false

                    } else if t.children != nil {
                        return true
                    }

                    if t.isFilledLeaf {

                        //                    for j in t.nodeIndices {
                        //                        if j != i {
                        //                            let k: V.Scalar =
                        //                            self.strength * alpha * self.precalculatedMass[j] / distanceSquared / distanceSquared.squareRoot()
                        //                            f += vec * k
                        //                        }
                        //                    }
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
            //        return forces
        }

    }

    /// Create a many-body force that simulate the many-body force.
    ///
    /// This is a very expensive force, the complexity is `O(n log(n))`,
    /// where `n` is the number of nodes. The complexity might degrade to `O(n^2)` if the nodes are too close to each other.
    /// The force mimics the gravity force or electrostatic force.
    /// See [Manybody Force - D3](https://d3js.org/d3-force/many-body).
    /// - Parameters:
    ///  - strength: The strength of the force. When the strength is positive, the nodes are attracted to each other like gravity force, otherwise, the nodes are repelled like electrostatic force.
    ///  - nodeMass: The mass of the nodes. The mass is used to calculate the force. The default value is 1.0.
    ///  - theta: Determines how approximate the calculation is. The default value is 0.9. The higher the value, the more approximate and fast the calculation is.
    @discardableResult
    @inlinable
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
}

extension SimulationKD.ManyBodyForce.NodeMass {
    @inlinable
    public func calculated(for simulation: SimulationKD<NodeID, V>) -> [V.Scalar] {
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
