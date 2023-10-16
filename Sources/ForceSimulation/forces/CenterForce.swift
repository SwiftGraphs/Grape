//
//  CenterForce.swift
//
//
//  Created by li3zhen1 on 10/16/23.
//
import NDTree

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
        for n in sim.nodes {
            meanPosition += n.position
        }
        let delta = meanPosition * (self.strength / Double(sim.nodes.count))

        for i in sim.nodes.indices {
            sim.nodes[i].position -= delta
        }
    }

}

extension Simulation {

    @discardableResult
    public func createCenterForce(center: V, strength: Double = 0.1) -> CenterForce<NodeID, V> {
        let f = CenterForce<NodeID, V>(center: center, strength: strength)
        f.simulation = self
        self.forces.append(f)
        return f
    }

}
