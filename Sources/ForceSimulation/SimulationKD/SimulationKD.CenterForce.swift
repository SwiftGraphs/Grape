//
//  CenterForce.swift
//
//
//  Created by li3zhen1 on 10/16/23.
//


extension SimulationKD {
    /// A force that drives nodes towards the center.
    /// Center force is relatively fast, the complexity is `O(n)`,
    /// where `n` is the number of nodes.
    /// See [Collide Force - D3](https://d3js.org/d3-force/collide).
    final public class CenterForce: ForceLike
    where NodeID: Hashable, V: VectorLike, V.Scalar : SimulatableFloatingPoint {

        public var center: V
        public var strength: V.Scalar
        weak var simulation: SimulationKD?

        internal init(center: V, strength: V.Scalar) {
            self.center = center
            self.strength = strength
        }

        public func apply() {
            guard let sim = self.simulation else { return }
            let alpha = sim.alpha

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

    /// Create a center force that drives nodes towards the center.
    /// Center force is relatively fast, the complexity is `O(n)`,
    /// where `n` is the number of nodes.
    /// See [Collide Force - D3](https://d3js.org/d3-force/collide).
    /// - Parameters:
    ///  - center: The center of the force.
    ///  - strength: The strength of the force.
    @discardableResult
    public func createCenterForce(center: V, strength: V.Scalar = 0.1) -> CenterForce {
        let f = CenterForce(center: center, strength: strength)
        f.simulation = self
        self.forces.append(f)
        return f
    }

}
