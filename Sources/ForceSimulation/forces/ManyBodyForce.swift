//
//  File.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

import QuadTree
import simd

struct MassQuadTreeDelegate<N>: QuadDelegate where N: Identifiable {

    typealias Node = N

    public var accumulatedProperty: Double = 0.0
    public var accumulatedCount = 0
    public var weightedAccumulatedNodePositions: Vector2f = .zero

    @usableFromInline let massProvider: (N.ID) -> Double

    init(
        massProvider: @escaping (N.ID) -> Double
    ) {
        self.massProvider = massProvider
    }

    internal init(
        initialAccumulatedProperty: Double,
        initialAccumulatedCount: Int,
        initialWeightedAccumulatedNodePositions: Vector2f,
        massProvider: @escaping (N.ID) -> Double
    ) {
        self.accumulatedProperty = initialAccumulatedProperty
        self.accumulatedCount = initialAccumulatedCount
        self.weightedAccumulatedNodePositions = initialWeightedAccumulatedNodePositions
        self.massProvider = massProvider
    }

    @inlinable mutating func didAddNode(_ node: N, at position: Vector2f) {
        let p = massProvider(node.id)
        accumulatedCount += 1
        accumulatedProperty += p
        weightedAccumulatedNodePositions += p * position
    }

    @inlinable mutating func didRemoveNode(_ node: N, at position: Vector2f) {
        let p = massProvider(node.id)
        accumulatedCount -= 1
        accumulatedProperty -= p
        weightedAccumulatedNodePositions -= p * position
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

    @inlinable func createNew() -> Self {
        return Self(massProvider: self.massProvider)
    }

    @inlinable var centroid: Vector2f? {
        guard accumulatedCount > 0 else { return nil }
        return weightedAccumulatedNodePositions / accumulatedProperty
    }
}

//final class MassQuadTreeDelegate<N>: QuadDelegate where N : Identifiable {
//
//    typealias Node = N
//    typealias Property = Double
//    typealias MassProvider = [N.ID: Double]
//
//    public var accumulatedProperty: Double = 0.0
//    public var accumulatedCount = 0
//    public var weightedAccumulatedNodePositions: Vector2f = .zero
//
//    let massProvider: [N.ID: Double]
//
//    init(
//        massProvider: MassProvider
//    ) {
//        self.massProvider = massProvider
//    }
//
//
//    internal init(
//        initialAccumulatedProperty: Double,
//        initialAccumulatedCount: Int,
//        initialWeightedAccumulatedNodePositions: Vector2f,
//        massProvider: MassProvider
//    ) {
//        self.accumulatedProperty = initialAccumulatedProperty
//        self.accumulatedCount = initialAccumulatedCount
//        self.weightedAccumulatedNodePositions = initialWeightedAccumulatedNodePositions
//        self.massProvider = massProvider
//    }
//
//    func didAddNode(_ node: N, at position: Vector2f) {
//        let p = massProvider[node.id, default: 0]
//        accumulatedCount += 1
//        accumulatedProperty += p
//        weightedAccumulatedNodePositions += p * position
//    }
//
//    func didRemoveNode(_ node: N, at position: Vector2f) {
//        let p = massProvider[node.id, default: 0]
//        accumulatedCount -= 1
//        accumulatedProperty -= p
//        weightedAccumulatedNodePositions -= p * position
//
//        // TODO: parent removal?
//    }
//
//
//    func copy() -> Self {
//        return Self(
//            initialAccumulatedProperty: self.accumulatedProperty,
//            initialAccumulatedCount: self.accumulatedCount,
//            initialWeightedAccumulatedNodePositions: self.weightedAccumulatedNodePositions,
//            massProvider: self.massProvider
//        )
//    }
//
//    func createNew() -> Self {
//        return Self(massProvider: self.massProvider)
//    }
//
//
//    var centroid : Vector2f? {
//        guard accumulatedCount > 0 else { return nil }
//        return weightedAccumulatedNodePositions / accumulatedProperty
//    }
//}

enum ManyBodyForceError: Error {
    case buildQuadTreeBeforeSimulationInitialized
}

final public class ManyBodyForce<N>: Force where N: Identifiable {

    var strength: Double = -20

    public enum NodeMass {
        case constant(Double)
        case varied([N.ID: Double])
    }
    var mass: NodeMass = .constant(1.0)
    var precalculatedMass: [N.ID: Double] = [:]

    weak var simulation: Simulation<N>? {
        didSet {
            guard let sim = self.simulation else { return }
            self.precalculatedMass = self.mass.calculated(nodes: sim.simulationNodes)
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

        for i in simulation.simulationNodes.indices {
            simulation.updateNode(index: i) { n in
                n.velocity += forces[i]
            }
        }
    }

    func calculateForce(alpha: Double) throws -> [Vector2f] {

        guard let sim = self.simulation else {
            throw ManyBodyForceError.buildQuadTreeBeforeSimulationInitialized
        }

        let quad = try QuadTree2(
            nodes: sim.simulationNodes.map { ($0, $0.position) }
        ) {
            // this switch is only called on root init 
            return switch self.mass {
            case .constant(let m):
                MassQuadTreeDelegate<SimulationNode<N.ID>> { _ in m }
            case .varied(_):
                MassQuadTreeDelegate<SimulationNode<N.ID>> {
                    self.precalculatedMass[$0, default: 0.0]
                }
            }
        }

        var forces = [Vector2f](repeating: .zero, count: sim.simulationNodes.count)

        for i in sim.simulationNodes.indices {
            quad.visit { quadNode in
                if let centroid = quadNode.quadDelegate.centroid {
                    let vec = centroid - sim.simulationNodes[i].position

                    var distanceSquared = vec.jiggled()
                        .lengthSquared()

                    // too far away, omit
                    guard distanceSquared < self.distanceMax2 else { return false }

                    // too close, enlarge distance
                    if distanceSquared < self.distanceMin2 {
                        distanceSquared = sqrt(self.distanceMin2 * distanceSquared)
                    }

                    if quadNode.isLeaf || (distanceSquared * self.theta2 > quadNode.quad.area) {

                        forces[i] +=
                            self.strength * alpha * quadNode.quadDelegate.accumulatedProperty * vec / distanceSquared / sqrt(distanceSquared)

                        return false
                    } else {
                        return true
                    }
                } else {
                    // it's empty here, no need to visit
                    return false
                }
            }
        }

        return forces
    }

}

extension ManyBodyForce.NodeMass {
    func calculated<SimNodes>(nodes: [SimNodes]) -> [N.ID: Double]
    where SimNodes: Identifiable, SimNodes.ID == N.ID {
        switch self {
        case .constant(let m):
            return Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, m) })
        case .varied(let massProvider):
            return massProvider
        }
    }
}

extension Simulation {

    @discardableResult
    public func createManyBodyForce(
        strength: Double,
        nodeMassPassProvider: ManyBodyForce<N>.NodeMass = .constant(1.0)
    ) -> ManyBodyForce<N> {
        let manyBodyForce = ManyBodyForce<N>(
            strength: strength, nodeMassProvider: nodeMassPassProvider)
        manyBodyForce.simulation = self
        self.forces.append(manyBodyForce)
        return manyBodyForce
    }

}
