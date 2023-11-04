//
//  ForceLike.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

import simd

/// A protocol that represents a force.
/// A force takes a simulation state and modifies its node positions and velocities.
public protocol ForceLike {

    /// Takes a simulation state and modifies its node positions and velocities.
    /// This is executed in each tick of the simulation.
    @inlinable func apply()
}

public protocol NDTreeBasedForceLike: ForceLike {
    associatedtype TD: NDTreeDelegate
}

// extension Simulation {

@resultBuilder
public struct ForceFieldBuilder {
    public static func buildBlock<each F>(_ forces: repeat each F) -> (repeat each F) {
        return (repeat each forces)
    }
}

public struct ForceField< /*NodeID, V, */each F>
where
    repeat each F: ForceLike  //, NodeID: Hashable, V: VectorLike, V.Scalar: SimulatableFloatingPoint
{

    @usableFromInline let forces: (repeat each F)

    @inlinable init(forces: repeat each F) {
        self.forces = (repeat each forces)
    }

    init(@ForceFieldBuilder _ builder: () -> (repeat each F)) {
        forces = builder()
    }

    @inlinable func append<NewForce: ForceLike>(_ newForce: NewForce) -> ForceField<
        repeat each F, NewForce
    > {
        return ForceField<repeat each F, NewForce>(forces: repeat each forces, newForce)
    }

    @inlinable func apply() {
        repeat (each forces).apply()
    }

    // public typealias SIM = SimulationKD<NodeID, V>

    // @discardableResult
    // @inlinable
    // public func withF1() -> ForceField<
    //     NodeID, V, repeat each F, F1
    // > {
    //     return ForceField<NodeID, V, repeat each F, F1>(
    //         forces: repeat each forces,
    //         F1()
    //     )
    // }
}

// }

// extension ForceLike {
//     @inlinable public func packWith<each F>(_ pack: Simulation.ForceField<repeat each F>) -> ForceField<
//         repeat each F, Self
//     > where repeat each F: ForceLike {
//         let result = pack.append(self)
//         return result
//     }
// }

public struct F1: ForceLike {
    @inlinable public func apply() {}
}

struct SimulationBuilder<NodeID, V, each Force>
where
    NodeID: Hashable, V: VectorLike, V.Scalar: SimulatableFloatingPoint,
    repeat each Force: ForceLike
{
    let forces: ForceField<repeat each Force>

    public typealias Sim = SimulationKD<NodeID, V>

    @inlinable init(forces: ForceField<repeat each Force>) {
        self.forces = forces
    }

    func withCenterForce(center: V, strength: V.Scalar = 0.1) -> SimulationBuilder<NodeID, V, repeat each Force, Sim.CenterForce> {
        let newForceField = self.forces.append(
            Sim.CenterForce(center: center, strength: strength)
        )
        return SimulationBuilder<NodeID, V, repeat each Force, Sim.CenterForce>(forces: newForceField)
    }

    func withCollideForce(
        radius: Sim.CollideForce.CollideRadius = .constant(3.0),
        strength: V.Scalar = 1.0,
        iterationsPerTick: UInt = 1
    ) -> SimulationBuilder<NodeID, V, repeat each Force, Sim.CollideForce> {
        let f = Sim.CollideForce(
            radius: radius,
            strength: strength,
            iterationsPerTick: iterationsPerTick
        )
        let newForceField = self.forces.append(f)
        
        return SimulationBuilder<NodeID, V, repeat each Force, Sim.CollideForce>(
            forces: newForceField
        )
    }

    func createLinkForce(
        _ linkTuples: [(NodeID, NodeID)],
        stiffness: Sim.LinkForce.LinkStiffness = .weightedByDegree { _, _ in 1.0 },
        originalLength: Sim.LinkForce.LinkLength = .constant(30.0),
        iterationsPerTick: UInt = 1
    ) -> SimulationBuilder<NodeID, V, repeat each Force, Sim.LinkForce> {
        let links = linkTuples.map { EdgeID($0.0, $0.1) }
        let linkForce = Sim.LinkForce(
            links, stiffness: stiffness, originalLength: originalLength)

        let newForceField = self.forces.append(linkForce)
        return SimulationBuilder<NodeID, V, repeat each Force, Sim.LinkForce>(
            forces: newForceField
        )
    }
}
