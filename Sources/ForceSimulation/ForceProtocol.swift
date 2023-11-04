//
//  ForceLike.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

import simd

/// A protocol that represents a force.
/// A force takes a simulation state and modifies its node positions and velocities.
public protocol ForceProtocol {

    associatedtype NodeID: Hashable
    associatedtype V: VectorLike where V.Scalar: SimulatableFloatingPoint

    /// Takes a simulation state and modifies its node positions and velocities.
    /// This is executed in each tick of the simulation.
    @inlinable func apply()

    /// Bind the force to a simulation state.
    /// This is called when the force is created on a simulation.
    @inlinable func bindSimulation(_ simulation: SimulationState<NodeID, V>?)

}

// extension Simulation {

// @resultBuilder
// public struct ForceFieldBuilder {
//     public static func buildBlock<each F>(_ forces: repeat each F) -> (repeat each F) {
//         return (repeat each forces)
//     }
// }

// public struct ForceField< /*NodeID, V, */each F>
// where
//     repeat each F: ForceLike  //, NodeID: Hashable, V: VectorLike, V.Scalar: SimulatableFloatingPoint
// {

//     @usableFromInline let forces: (repeat each F)

//     @inlinable init(forces: repeat each F) {
//         self.forces = (repeat each forces)
//     }

//     init(@ForceFieldBuilder _ builder: () -> (repeat each F)) {
//         forces = builder()
//     }

//     @inlinable func append<NewForce: ForceLike>(_ newForce: NewForce) -> ForceField<
//         repeat each F, NewForce
//     > {
//         return ForceField<repeat each F, NewForce>(forces: repeat each forces, newForce)
//     }

//     @inlinable func apply() {
//         repeat (each forces).apply()
//     }

//     @inlinable public static var empty: ForceField<EmptyForce> {
//         return ForceField<EmptyForce>(
//             forces: EmptyForce()
//         )
//     }

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
// }

// }

// extension ForceLike {
//     @inlinable public func packWith<each F>(_ pack: Simulation.ForceField<repeat each F>) -> ForceField<
//         repeat each F, Self
//     > where repeat each F: ForceLike {
//         let result = pack.append(self)
//         return result
//     }
// }

// public struct F1: ForceLike {
//     @inlinable public func apply() {}
// }

// public struct SimulationBuilder<NodeID, V, F>
// where
//     NodeID: Hashable, V: VectorLike, V.Scalar: SimulatableFloatingPoint, F: ForceLike
// {
//     public let forces: F

//     public typealias Sim = SimulationKD<NodeID, V>

//     @inlinable public init(forces: F) {
//         self.forces = forces
//     }

//     @discardableResult
//     @inlinable public func withCenterForce(center: V, strength: V.Scalar = 0.1)
//         -> SimulationBuilder<NodeID, V, ForceTuple<F, Sim.CenterForce>>
//     {
//         return SimulationBuilder<NodeID, V, ForceTuple<F, Sim.CenterForce>>(
//             forces: ForceTuple(forces, Sim.CenterForce(center: center, strength: strength)))
//     }

//     @discardableResult
//     @inlinable public func withCollideForce(
//         radius: Sim.CollideForce.CollideRadius = .constant(3.0),
//         strength: V.Scalar = 1.0,
//         iterationsPerTick: UInt = 1
//     ) -> SimulationBuilder<NodeID, V, ForceTuple<F, Sim.CollideForce>> {
//         let f = Sim.CollideForce(
//             radius: radius,
//             strength: strength,
//             iterationsPerTick: iterationsPerTick
//         )

//         return SimulationBuilder<NodeID, V, ForceTuple<F, Sim.CollideForce>>(
//             forces: ForceTuple(forces, f)
//         )
//     }

//     @discardableResult
//     @inlinable public func withLinkForce(
//         _ linkTuples: [(NodeID, NodeID)],
//         stiffness: Sim.LinkForce.LinkStiffness = .weightedByDegree { _, _ in 1.0 },
//         originalLength: Sim.LinkForce.LinkLength = .constant(30.0),
//         iterationsPerTick: UInt = 1
//     ) -> SimulationBuilder<NodeID, V, ForceTuple<F, Sim.LinkForce>> {
//         let links = linkTuples.map { EdgeID($0.0, $0.1) }
//         let linkForce = Sim.LinkForce(
//             links, stiffness: stiffness, originalLength: originalLength)

//         return SimulationBuilder<NodeID, V, ForceTuple<F, Sim.LinkForce>>(
//             forces: ForceTuple(forces, linkForce)
//         )
//     }

//     @discardableResult
//     @inlinable public func withManyBodyForce(
//         strength: V.Scalar,
//         nodeMass: Sim.ManyBodyForce.NodeMass = .constant(1.0)
//     ) -> SimulationBuilder<NodeID, V, ForceTuple<F, Sim.ManyBodyForce>> {
//         let manyBodyForce = Sim.ManyBodyForce(
//             strength: strength, nodeMass: nodeMass)

//         // let newForceField = self.forces.append(manyBodyForce)
//         return SimulationBuilder<NodeID, V, ForceTuple<F, Sim.ManyBodyForce>>(
//             forces: ForceTuple(forces, manyBodyForce)
//         )
//     }

// }


