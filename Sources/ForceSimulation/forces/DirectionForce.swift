//
//  PositionForce.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

import NDTree

/// A force that moves nodes to a target position.
final public class DirectionForce<NodeID, V>: ForceLike
where NodeID: Hashable, V: VectorLike, V.Scalar == Double {

    public enum Direction {
        case x
        case y
        case entryOfVector(Int)
    }
    public enum Strength {
        case constant(Double)
        case varied((NodeID) -> Double)
    }

    public enum TargetOnDirection {
        case constant(V.Scalar)
        case varied((NodeID) -> V.Scalar)
    }

    public var strength: Strength
    public var direction: Int
    public var calculatedStrength: [Double] = []
    public var targetOnDirection: TargetOnDirection
    public var calculatedTargetOnDirection: [V.Scalar] = []

    internal init(
        direction: Direction, targetOnDirection: TargetOnDirection,
        strength: Strength = .constant(1.0)
    ) {

        self.strength = strength
        self.direction = direction.lane
        self.targetOnDirection = targetOnDirection
    }

    weak var simulation: Simulation<NodeID, V>? {
        didSet {
            guard let sim = self.simulation else { return }
            self.calculatedStrength = strength.calculated(for: sim)
            self.calculatedTargetOnDirection = targetOnDirection.calculated(for: sim)
        }
    }

    public func apply(alpha: Double) {
        guard let sim = self.simulation else { return }
        let lane = self.direction
        for i in sim.nodePositions.indices {
            sim.nodeVelocities[i][lane] +=
                (self.calculatedTargetOnDirection[i] - sim.nodePositions[i][lane])
                * self.calculatedStrength[i] * alpha
        }
    }
}

extension DirectionForce.Strength: PrecalculatableNodeProperty {
    public func calculated(for simulation: Simulation<NodeID, V>) -> [Double] {
        switch self {
        case .constant(let value):
            return Array(repeating: value, count: simulation.nodeIds.count)
        case .varied(let getter):
            return simulation.nodeIds.map(getter)
        }
    }
}

extension DirectionForce.TargetOnDirection: PrecalculatableNodeProperty {
    public func calculated(for simulation: Simulation<NodeID, V>) -> [Double] {
        switch self {
        case .constant(let value):
            return Array(repeating: value, count: simulation.nodeIds.count)
        case .varied(let getter):
            return simulation.nodeIds.map(getter)
        }
    }
}

extension DirectionForce.Direction {
    @inlinable var lane: Int {
        switch self {
        case .x: return 0
        case .y: return 1
        case .entryOfVector(let i): return i
        }
    }
}

extension Simulation {

    /// Create a direction force, Similar to https://d3js.org/d3-force/position
    @discardableResult
    public func createPositionForce(
        direction: DirectionForce<NodeID, V>.Direction,
        targetOnDirection: DirectionForce<NodeID, V>.TargetOnDirection,
        strength: DirectionForce<NodeID, V>.Strength = .constant(1.0)
    ) -> DirectionForce<NodeID, V> {
        let force = DirectionForce<NodeID, V>(
            direction: direction,
            targetOnDirection: targetOnDirection,
            strength: strength
        )
        force.simulation = self
        self.forces.append(force)
        return force
    }
}
