//
//  ForceLike.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

import NDTree

/// A protocol that represents a force.
/// A force takes a simulation state and modifies its node positions and velocities.
public protocol ForceLike {
    associatedtype NodeID: Hashable

    /// Takes a simulation state and modifies its node positions and velocities. 
    /// This is executed in each tick of the simulation.
    func apply(alpha: Double)
}

public protocol NDTreeBasedForceLike: ForceLike {
    associatedtype TD: NDTreeDelegate
}

extension Array where Element: NDTreeBasedForceLike {
    public func combined() {

    }
}
