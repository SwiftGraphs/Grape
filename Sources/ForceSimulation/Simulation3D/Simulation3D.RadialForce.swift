//
//  RadialForce.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

#if canImport(simd)

import simd

extension Simulation3D {
    /// A force that applies a radial force to all nodes.
    /// Center force is relatively fast, the complexity is `O(n)`,
    /// where `n` is the number of nodes.
    /// See [Position Force - D3](https://d3js.org/d3-force/position).
    final public class RadialForce: ForceLike
    where NodeID: Hashable {

        weak var simulation: Simulation3D<NodeID>? {
            didSet {
                guard let sim = self.simulation else { return }
                self.calculatedStrength = strength.calculated(for: sim)
                self.calculatedRadius = radius.calculated(for: sim)
            }
        }

        public var center: V

        /// Radius accessor
        public enum NodeRadius {
            case constant(V.Scalar)
            case varied((NodeID) -> V.Scalar)
        }
        public var radius: NodeRadius
        private var calculatedRadius: [V.Scalar] = []

        /// Strength accessor
        public enum Strength {
            case constant(V.Scalar)
            case varied((NodeID) -> V.Scalar)
        }
        public var strength: Strength
        private var calculatedStrength: [V.Scalar] = []

        public init(center: V, radius: NodeRadius, strength: Strength) {
            self.center = center
            self.radius = radius
            self.strength = strength
        }

        public func apply() {
            guard let sim = self.simulation else { return }
            let alpha = sim.alpha
            for i in sim.nodePositions.indices {
                let nodeId = i

                let deltaPosition = (sim.nodePositions[i] - self.center).jiggled()
                let r = simd_length(deltaPosition)
                let k =
                    (self.calculatedRadius[nodeId]
                        * self.calculatedStrength[nodeId] * alpha) / r
                sim.nodeVelocities[i] += deltaPosition * k
            }
        }

    }

    /// Create a radial force that applies a radial force to all nodes.
    /// Center force is relatively fast, the complexity is `O(n)`,
    /// where `n` is the number of nodes.
    /// See [Position Force - D3](https://d3js.org/d3-force/position).
    /// - Parameters:
    ///   - center: The center of the force.
    ///   - radius: The radius of the force.
    ///   - strength: The strength of the force.
    @discardableResult
    public func createRadialForce(
        center: V = .zero,
        radius: RadialForce.NodeRadius,
        strength: RadialForce.Strength = .constant(0.1)
    ) -> RadialForce {
        let f = RadialForce(center: center, radius: radius, strength: strength)
        f.simulation = self
        self.forces.append(f)
        return f
    }

}

extension Simulation3D.RadialForce.Strength {
    public func calculated(for simulation: Simulation3D<NodeID>) -> [Float] {
        switch self {
        case .constant(let s):
            return simulation.nodeIds.map { _ in s }
        case .varied(let s):
            return simulation.nodeIds.map(s)
        }
    }
}

extension Simulation3D.RadialForce.NodeRadius {
    public func calculated(for simulation: Simulation3D<NodeID>) -> [Float] {
        switch self {
        case .constant(let r):
            return simulation.nodeIds.map { _ in r }
        case .varied(let r):
            return simulation.nodeIds.map(r)
        }
    }
}

#endif