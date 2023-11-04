//
//  ForceLike.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

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

@resultBuilder
public struct ForceFieldBuilder {
    public static func buildBlock<each F>(_ forces: repeat each F) -> (repeat each F) {
        return (repeat each forces)
    }
}

public struct ForceField<each F> where repeat each F: ForceLike {

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
}

extension ForceLike {
    @inlinable public func packWith<each F>(_ pack: ForceField<repeat each F>) -> ForceField<
        repeat each F, Self
    > where repeat each F: ForceLike {
        return pack.append(self)
    }
}
