//
//  File.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

import NDTree

enum ManyBodyForceError: Error {
    case buildQuadTreeBeforeSimulationInitialized
}

struct MassQuadtreeDelegate<NodeID, V>: NDTreeDelegate where NodeID: Hashable, V: VectorLike {

    public var accumulatedMass: Double = .zero
    public var accumulatedCount = 0
    public var accumulatedMassWeightedPositions: V = .zero

    @usableFromInline let massProvider: (NodeID) -> Double

    init(
        massProvider: @escaping (NodeID) -> Double
    ) {
        self.massProvider = massProvider
    }

    internal init(
        initialAccumulatedProperty: Double,
        initialAccumulatedCount: Int,
        initialWeightedAccumulatedNodePositions: V,
        massProvider: @escaping (NodeID) -> Double
    ) {
        self.accumulatedMass = initialAccumulatedProperty
        self.accumulatedCount = initialAccumulatedCount
        self.accumulatedMassWeightedPositions = initialWeightedAccumulatedNodePositions
        self.massProvider = massProvider
    }

    @inlinable mutating func didAddNode(_ node: NodeID, at position: V) {
        let p = massProvider(node)
        accumulatedCount += 1
        accumulatedMass += p
        accumulatedMassWeightedPositions += position * p
    }

    @inlinable mutating func didRemoveNode(_ node: NodeID, at position: V) {
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

    @inlinable var centroid: V? {
        guard accumulatedCount > 0 else { return nil }
        return accumulatedMassWeightedPositions / accumulatedMass
    }
}

final public class ManyBodyForce<NodeID, V>: ForceLike
where NodeID: Hashable, V: VectorLike, V.Scalar == Double {

    var strength: Double = -20

    public enum NodeMass {
        case constant(Double)
        case varied(lookup: [NodeID: Double], default: Double)
    }
    var mass: NodeMass = .constant(1.0)
    var precalculatedMass: [Double] = []

    weak var simulation: Simulation<NodeID, V>? {
        didSet {
            guard let sim = self.simulation else { return }
            self.precalculatedMass = self.mass.calculated(for: sim)
        }
    }

    var theta2: Double = 0.81
    var theta: Double { theta2.squareRoot() }

    var distanceMin2: Double = 0.01
    var distanceMax2: Double = Double.infinity
    var distanceMin: Double = 0.1
    var distanceMax: Double = Double.infinity

    internal init(
        strength: Double,
        nodeMass: NodeMass = .constant(1.0)
    ) {
        self.strength = strength
        self.mass = nodeMass
    }

    public func apply(alpha: Double) {
        guard let simulation,
            let forces = try? calculateForce(alpha: alpha)
        else { return }

        for i in simulation.nodes.indices {
            simulation.nodeVelocities[i] += forces[i]
            
        }
    }
    
    private func getCoveringBox() throws -> NDBox<V> {
        guard let simulation else { throw ManyBodyForceError.buildQuadTreeBeforeSimulationInitialized }
        var _p0 = simulation.nodes[0].position
        var _p1 = simulation.nodes[0].position
        
        for p in simulation.nodes {
            for i in 0..<V.scalarCount {
                if p.position[i] < _p0[i] {
                    _p0[i] = p.position[i]
                }
                if p.position[i] >= _p1[i] {
                    _p1[i] = p.position[i] + 1
                }
            }
        }
        return NDBox(_p0, _p1)
        
    }

    func calculateForce(alpha: Double) throws -> [V] {

        guard let sim = self.simulation else {
            throw ManyBodyForceError.buildQuadTreeBeforeSimulationInitialized
        }

        
        let coveringBox = NDBox<V>.cover(of: sim.nodePositions) //try! getCoveringBox()

        let tree = NDTree<V, MassQuadtreeDelegate<Int, V>>(box: coveringBox, clusterDistance: 1e-7)
        {
            
            return switch self.mass {
            case .constant(let m):
                MassQuadtreeDelegate<Int, V> { _ in m }
            case .varied(_, _):
                MassQuadtreeDelegate<Int, V> { index in
                    self.precalculatedMass[index]
                }
            }
            

        }
        
        for i in sim.nodePositions.indices {
            tree.add(i, at: sim.nodePositions[i])
            assert(tree.delegate.accumulatedCount == i+1)
        }

        var forces = [V](repeating: .zero, count: sim.nodePositions.count)
        
        for i in sim.nodePositions.indices {
//            var f = V.zero
            tree.visit { t in
                guard t.delegate.accumulatedCount > 0 else { return false }
                let centroid = t.delegate.accumulatedMassWeightedPositions / t.delegate.accumulatedMass

                let vec = centroid - sim.nodePositions[i]
                var distanceSquared = vec.jiggled().lengthSquared()

                guard distanceSquared < self.distanceMax2 else { return false }
                
            
                if distanceSquared < self.distanceMin2 {
                    distanceSquared = (self.distanceMin2 * distanceSquared).squareRoot()
                }

                let boxSize = (t.box.p1 - t.box.p0)[0]
                
                let farEnough: Bool = (distanceSquared * self.theta2) > (boxSize * boxSize)

                if tree.isLeaf || farEnough {
                    /// Workaround for "The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions"
                    let k: Double = self.strength * alpha * t.delegate.accumulatedMass / distanceSquared / distanceSquared.squareRoot()
                    forces[i] += vec * k
//                    f = f + (vec * k)
                    return false
                }
                else {
                    return true
                }

//                return !shouldAccumulateForce  // if accumulated, no need to visit children
            }
            forces[i] /= self.precalculatedMass[i]
        }
        return forces
    }

}

extension ManyBodyForce.NodeMass: PrecalculatableNodeProperty {
    public func calculated(for simulation: Simulation<NodeID, V>) -> [Double] {
        switch self {
        case .constant(let m):
            return Array(repeating: m, count: simulation.nodes.count)
        case .varied(let massDict, let defaultMass):
            return simulation.nodeIds.map { n in
                return massDict[n, default: defaultMass]
            }
        }
    }
}

extension Simulation {

    @discardableResult
    public func createManyBodyForce(
        strength: Double,
        nodeMass: ManyBodyForce<NodeID, V>.NodeMass = .constant(1.0)
    ) -> ManyBodyForce<NodeID, V> {
        let manyBodyForce = ManyBodyForce<NodeID, V>(
            strength: strength, nodeMass: nodeMass)
        manyBodyForce.simulation = self
        self.forces.append(manyBodyForce)
        return manyBodyForce
    }
}
