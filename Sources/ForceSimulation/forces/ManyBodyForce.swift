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

    public var accumulatedProperty: Double = .zero
    public var accumulatedCount = 0
    public var weightedAccumulatedNodePositions: V = .zero

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
        self.accumulatedProperty = initialAccumulatedProperty
        self.accumulatedCount = initialAccumulatedCount
        self.weightedAccumulatedNodePositions = initialWeightedAccumulatedNodePositions
        self.massProvider = massProvider
    }

    @inlinable mutating func didAddNode(_ node: NodeID, at position: V) {
        let p = massProvider(node)
        accumulatedCount += 1
        accumulatedProperty += p
        weightedAccumulatedNodePositions += position * p
    }

    @inlinable mutating func didRemoveNode(_ node: NodeID, at position: V) {
        let p = massProvider(node)
        accumulatedCount -= 1
        accumulatedProperty -= p
        weightedAccumulatedNodePositions -= position * p
        // TODO: parent removal?
    }

    @inlinable func copy() -> Self {
        return Self(
            initialAccumulatedProperty: self.accumulatedProperty,
            initialAccumulatedCount: self.accumulatedCount,
            initialWeightedAccumulatedNodePositions: self.weightedAccumulatedNodePositions,
            massProvider: self.massProvider
        )
    }

    @inlinable func spawn() -> Self {
        return Self(massProvider: self.massProvider)
    }

    @inlinable var centroid: V? {
        guard accumulatedCount > 0 else { return nil }
        return weightedAccumulatedNodePositions / accumulatedProperty
    }
}




final public class ManyBodyForce<NodeID, V>: ForceLike where NodeID: Hashable, V: VectorLike, V.Scalar == Double {
    
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

    internal init(
        strength: Double,
        nodeMassProvider: NodeMass = .constant(1.0)
    ) {
        self.strength = strength
        self.mass = nodeMassProvider
    }

    public func apply(alpha: Double) {
        guard let simulation,
            let forces = try? calculateForce(alpha: alpha)
        else { return }

        for i in simulation.nodes.indices {
            simulation.nodes[i].velocity += forces[i]
        }
    }

    func calculateForce(alpha: Double) throws -> [V] {

        guard let sim = self.simulation else {
            throw ManyBodyForceError.buildQuadTreeBeforeSimulationInitialized
        }
        return []
        

//        let quad = try QuadTree2(
//            nodes: sim.simulationNodes.map { ($0, $0.position) }
//        ) {
//            // this switch is only called on root init
//            return switch self.mass {
//            case .constant(let m):
//                MassQuadTreeDelegate<SimulationNode<N.ID>> { _ in m }
//            case .varied(_):
//                MassQuadTreeDelegate<SimulationNode<N.ID>> {
//                    self.precalculatedMass[$0, default: 0.0]
//                }
//            }
//        }
//
//        var forces = [Vector2f](repeating: .zero, count: sim.simulationNodes.count)
//
//        for i in sim.simulationNodes.indices {
//            quad.visit { quadNode in
//                if let centroid = quadNode.quadDelegate.centroid {
//                    let vec = centroid - sim.simulationNodes[i].position
//
//                    var distanceSquared = vec.jiggled()
//                        .lengthSquared()
//
//                    // too far away, omit
//                    guard distanceSquared < self.distanceMax2 else { return false }
//
//                    // too close, enlarge distance
//                    if distanceSquared < self.distanceMin2 {
//                        distanceSquared = sqrt(self.distanceMin2 * distanceSquared)
//                    }
//
//                    if quadNode.isLeaf || (distanceSquared * self.theta2 > quadNode.quad.area) {
//
//                        forces[i] +=
//                            self.strength * alpha * quadNode.quadDelegate.accumulatedProperty * vec / distanceSquared / sqrt(distanceSquared)
//
//                        return false
//                    } else {
//                        return true
//                    }
//                } else {
//                    // it's empty here, no need to visit
//                    return false
//                }
//            }
//        }

//        return forces
    }

}

extension ManyBodyForce.NodeMass {
    func calculated(for sim: Simulation<NodeID, V>) -> [Double] {
        switch self {
        case .constant(let m):
            return Array(repeating: m, count: sim.nodes.count)
        case .varied(let massDict, let defaultMass):
            return sim.nodeIds.map { n in
                return massDict[n, default: defaultMass]
            }
        }
    }
}

extension Simulation {

    @discardableResult
    public func createManyBodyForce(
        strength: Double,
        nodeMassPassProvider: ManyBodyForce<NodeID, V>.NodeMass = .constant(1.0)
    ) -> ManyBodyForce<NodeID, V> {
        let manyBodyForce = ManyBodyForce<NodeID, V>(
            strength: strength, nodeMassProvider: nodeMassPassProvider)
        manyBodyForce.simulation = self
        self.forces.append(manyBodyForce)
        return manyBodyForce
    }
}
