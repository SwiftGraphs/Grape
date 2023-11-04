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
