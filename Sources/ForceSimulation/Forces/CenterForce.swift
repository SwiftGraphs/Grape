//
//  CenterForce.swift
//
//
//  Created by li3zhen1 on 10/16/23.
//

/// A force that drives nodes towards the center.
/// Center force is relatively fast, the complexity is `O(n)`,
/// where `n` is the number of nodes.
/// See [Collide Force - D3](https://d3js.org/d3-force/collide).
final public class CenterForce<NodeID, V>: ForceProtocol
where NodeID: Hashable, V: VectorLike, V.Scalar: SimulatableFloatingPoint {
    @inlinable public func bindSimulation(_ simulation: SimulationState<NodeID, V>?) {
        self.simulation = simulation
    }

    public var center: V
    public var strength: V.Scalar
    @usableFromInline weak var simulation: SimulationState<NodeID, V>?

    @inlinable init(center: V, strength: V.Scalar) {
        self.center = center
        self.strength = strength
    }

    @inlinable public func apply() {

        guard let sim = self.simulation else { return }
        //            let alpha = sim.alpha

        var meanPosition = V.zero
        for n in sim.nodePositions {
            meanPosition += n  //.position
        }
        let delta = meanPosition * (self.strength / V.Scalar(sim.nodePositions.count))

        for i in sim.nodePositions.indices {
            sim.nodePositions[i] -= delta
        }
    }
}

extension Simulation {
    @inlinable
    public func createCenterForce(center: V, strength: V.Scalar = 0.1) -> Simulation<
        NodeID, V, ForceTuple<NodeID, V, F, CenterForce<NodeID, V>>
    > where F.NodeID == NodeID, F.V == V {
        let f = CenterForce<NodeID, V>(center: center, strength: strength)
//        f.bindSimulation(self.simulation)
        return with(f)
    }
}
