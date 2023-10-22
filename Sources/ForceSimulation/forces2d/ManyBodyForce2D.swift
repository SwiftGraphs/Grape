//
//  File.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

import NDTree
import simd

enum ManyBodyForce2DError: Error {
    case buildQuadTreeBeforeSimulationInitialized
}

struct MassQuadtreeDelegate2D<NodeID>: QuadtreeDelegate where NodeID: Hashable {


    public var accumulatedMass: Double = .zero
    public var accumulatedCount: Int = 0
    public var accumulatedMassWeightedPositions: simd_double2 = .zero

    @usableFromInline let massProvider: (NodeID) -> Double

    init(
        massProvider: @escaping (NodeID) -> Double
    ) {
        self.massProvider = massProvider
    }

    internal init(
        initialAccumulatedProperty: Double,
        initialAccumulatedCount: Int,
        initialWeightedAccumulatedNodePositions: simd_double2,
        massProvider: @escaping (NodeID) -> Double
    ) {
        self.accumulatedMass = initialAccumulatedProperty
        self.accumulatedCount = initialAccumulatedCount
        self.accumulatedMassWeightedPositions = initialWeightedAccumulatedNodePositions
        self.massProvider = massProvider
    }

    @inlinable mutating func didAddNode(_ node: NodeID, at position: simd_double2) {
        let p = massProvider(node)
        #if DEBUG
            assert(p > 0)
        #endif
        accumulatedCount += 1
        accumulatedMass += p
        accumulatedMassWeightedPositions += position * p
    }

    @inlinable mutating func didRemoveNode(_ node: NodeID, at position: simd_double2) {
        let p = massProvider(node)
        accumulatedCount -= 1
        accumulatedMass -= p
        accumulatedMassWeightedPositions -= position * p
        // TODO: parent removal?
    }

    @inlinable func copy() -> Self {
        return Self(
            initialAccumulatedProperty: self.accumulatedMass,
            initialAccumulatedCount: self.accumulatedCount,
            initialWeightedAccumulatedNodePositions: self.accumulatedMassWeightedPositions,
            massProvider: self.massProvider
        )
    }

    @inlinable func spawn() -> Self {
        return Self(massProvider: self.massProvider)
    }

    // @inlinable var centroid: simd_double2? {
    //     guard accumulatedCount > 0 else { return nil }
    //     return self.accumulatedMassWeightedPositions/self.accumulatedMass
    // }
}

/// A force that simulate the many-body force. 
/// This is a very expensive force, the complexity is `O(n log(n))`,
/// where `n` is the number of nodes. The complexity might degrade to `O(n^2)` if the nodes are too close to each other.
/// See [Manybody Force - D3](https://d3js.org/d3-force/many-body).
final public class ManyBodyForce2D<NodeID>: ForceLike
where NodeID: Hashable {


    var strength: Double

    public enum NodeMass {
        case constant(Double)
        case varied((NodeID) -> Double)
    }
    var mass: NodeMass
    var precalculatedMass: [Double] = []

    weak var simulation: Simulation2D<NodeID>? {
        didSet {
            guard let sim = self.simulation else { return }
            self.precalculatedMass = self.mass.calculated(for: sim)
            self.forces = [simd_double2](repeating: .zero, count: sim.nodePositions.count)
        }
    }

    var theta2: Double
    var theta: Double {
        didSet {
            theta2 = theta * theta
        }
    }

    var distanceMin2: Double = 1
    var distanceMax2: Double = Double.infinity
    var distanceMin: Double = 1
    var distanceMax: Double = Double.infinity

    internal init(
        strength: Double,
        nodeMass: NodeMass = .constant(1.0),
        theta: Double = 0.9
    ) {
        self.strength = strength
        self.mass = nodeMass
        self.theta = theta
        self.theta2 = theta * theta
    }

    var forces: [simd_double2] = []
    public func apply() {
        guard let simulation else { return }
        
        let alpha = simulation.alpha
        
        try! calculateForce(alpha: alpha)  //else { return }

        for i in simulation.nodeVelocities.indices {
            simulation.nodeVelocities[i] += self.forces[i] / precalculatedMass[i]
        }
    }

    //    private func getCoveringBox() throws -> NDBox<simd_double2> {
    //        guard let simulation else { throw ManyBodyForceError.buildQuadTreeBeforeSimulationInitialized }
    //        var _p0 = simulation.nodes[0].position
    //        var _p1 = simulation.nodes[0].position
    //
    //        for p in simulation.nodes {
    //            for i in 0..<simd_double2.scalarCount {
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

    func calculateForce(alpha: Double) throws {

        guard let sim = self.simulation else {
            throw ManyBodyForceError.buildQuadTreeBeforeSimulationInitialized
        }

        let coveringBox = QuadBox.cover(of: sim.nodePositions)  //try! getCoveringBox()

        let tree = Quadtree<MassQuadtreeDelegate2D>(box: coveringBox, clusterDistance: 1e-5)
        {

            return switch self.mass {
            case .constant(let m):
                MassQuadtreeDelegate2D<Int> { _ in m }
            case .varied(_):
                MassQuadtreeDelegate2D<Int> { index in
                    self.precalculatedMass[index]
                }
            }
        }

        for i in sim.nodePositions.indices {
            tree.add(i, at: sim.nodePositions[i])

            #if DEBUG
                assert(tree.delegate.accumulatedCount == (i + 1))
            #endif

        }

        //        var forces = [simd_double2](repeating: .zero, count: sim.nodePositions.count)

        for i in sim.nodePositions.indices {
            var f = simd_double2.zero
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
                //                        let k: Double = self.strength * alpha * t.delegate.accumulatedMass / distanceSquared / (distanceSquared).squareRoot()
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
                //                        let k: Double = self.strength * alpha * t.delegate.accumulatedMass / distanceSquared / (distanceSquared).squareRoot()
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
                var distanceSquared = simd_length_squared(vec.jiggled())

                let farEnough: Bool = (distanceSquared * self.theta2) > (boxWidth * boxWidth)

                //                let distance = distanceSquared.squareRoot()

                if distanceSquared < self.distanceMin2 {
                    distanceSquared = (self.distanceMin2 * distanceSquared).squareRoot()
                }

                if farEnough {

                    guard distanceSquared < self.distanceMax2 else { return true }

                    /// Workaround for "The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions"
                    let k: Double =
                        self.strength * alpha * t.delegate.accumulatedMass / distanceSquared  // distanceSquared.squareRoot()

                    f += vec * k
                    return false

                } else if t.children != nil {
                    return true
                }

                if t.isFilledLeaf {

                    //                    for j in t.nodeIndices {
                    //                        if j != i {
                    //                            let k: Double =
                    //                            self.strength * alpha * self.precalculatedMass[j] / distanceSquared / distanceSquared.squareRoot()
                    //                            f += vec * k
                    //                        }
                    //                    }
                    if t.nodeIndices.contains(i) { return false }

                    let massAcc = t.delegate.accumulatedMass
                    //                    t.nodeIndices.contains(i) ?  (t.delegate.accumulatedMass-self.precalculatedMass[i]) : (t.delegate.accumulatedMass)
                    let k: Double = self.strength * alpha * massAcc / distanceSquared  // distanceSquared.squareRoot()
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

extension ManyBodyForce2D.NodeMass {
    public func calculated(for simulation: Simulation2D<NodeID>) -> [Double] {
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

extension Simulation2D {
    /// Create a many-body force that simulate the many-body force. 
    /// This is a very expensive force, the complexity is `O(n log(n))`,
    /// where `n` is the number of nodes. The complexity might degrade to `O(n^2)` if the nodes are too close to each other.
    /// The force mimics the gravity force or electrostatic force.
    /// See [Manybody Force - D3](https://d3js.org/d3-force/many-body).
    /// - Parameters:
    ///  - strength: The strength of the force. When the strength is positive, the nodes are attracted to each other like gravity force, otherwise, the nodes are repelled like electrostatic force.
    ///  - nodeMass: The mass of the nodes. The mass is used to calculate the force. The default value is 1.0.
    ///  - theta: Determines how approximate the calculation is. The default value is 0.9. The higher the value, the more approximate and fast the calculation is.
    @discardableResult
    public func createManyBodyForce(
        strength: Double,
        nodeMass: ManyBodyForce2D<NodeID>.NodeMass = .constant(1.0)
    ) -> ManyBodyForce2D<NodeID> {
        let manyBodyForce = ManyBodyForce2D<NodeID>(
            strength: strength, nodeMass: nodeMass)
        manyBodyForce.simulation = self
        self.forces.append(manyBodyForce)
        return manyBodyForce
    }
}
