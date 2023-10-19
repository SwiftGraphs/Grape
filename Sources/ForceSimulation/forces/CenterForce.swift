//
//  CenterForce.swift
//
//
//  Created by li3zhen1 on 10/16/23.
//
import NDTree

/// A force that drives nodes towards the center.
final public class CenterForce<NodeID, V>: ForceLike
where NodeID: Hashable, V: VectorLike, V.Scalar == Double {
    public var center: V
    public var strength: Double
    weak var simulation: Simulation<NodeID, V>?

    internal init(center: V, strength: Double) {
        self.center = center
        self.strength = strength
    }

    public func apply(alpha: Double) {
        guard let sim = self.simulation else { return }

        var meanPosition = V.zero
        for n in sim.nodePositions {
            meanPosition += n  //.position
        }
        let delta = meanPosition * (self.strength / Double(sim.nodePositions.count))

        for i in sim.nodePositions.indices {
            sim.nodePositions[i] -= delta
        }
    }

}

extension Simulation {

    /// Create a center force, See: https://d3js.org/d3-force/center
    @discardableResult
    public func createCenterForce(center: V, strength: Double = 0.1) -> CenterForce<NodeID, V> {
        let f = CenterForce<NodeID, V>(center: center, strength: strength)
        f.simulation = self
        self.forces.append(f)
        return f
    }

}
