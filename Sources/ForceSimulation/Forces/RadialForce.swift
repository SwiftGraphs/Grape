final public class RadialForce<NodeID, V>: ForceProtocol
where NodeID: Hashable, V: VectorLike, V.Scalar: SimulatableFloatingPoint {
    @usableFromInline weak var simulation: SimulationState<NodeID, V>?

    @inlinable
    public func bindSimulation(_ simulation: SimulationState<NodeID, V>?) {
        self.simulation = simulation
        guard let sim = self.simulation else { return }
        self.calculatedStrength = strength.calculated(for: sim)
        self.calculatedRadius = radius.calculated(for: sim)
    }

    public var center: V

    /// Radius accessor
    public enum NodeRadius {
        case constant(V.Scalar)
        case varied((NodeID) -> V.Scalar)
    }
    public var radius: NodeRadius
    @usableFromInline var calculatedRadius: [V.Scalar] = []

    /// Strength accessor
    public enum Strength {
        case constant(V.Scalar)
        case varied((NodeID) -> V.Scalar)
    }
    public var strength: Strength
    @usableFromInline var calculatedStrength: [V.Scalar] = []

    @inlinable public init(center: V, radius: NodeRadius, strength: Strength) {
        self.center = center
        self.radius = radius
        self.strength = strength
    }

    @inlinable public func apply() {
        guard let sim = self.simulation else { return }
        let alpha = sim.alpha
        for i in sim.nodePositions.indices {
            let nodeId = i
            let deltaPosition = (sim.nodePositions[i] - self.center).jiggled()
            let r = deltaPosition.length()
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
// @discardableResult
// @inlinable public func withRadialForce(
//     center: V = .zero,
//     radius: RadialForce.NodeRadius,
//     strength: RadialForce.Strength = .constant(0.1)
// ) -> RadialForce {
//     let f = RadialForce(center: center, radius: radius, strength: strength)
//     f.simulation = self
//     self.forces.append(f)
//     return f
// }

extension RadialForce.Strength {
    @inlinable public func calculated(for simulation: SimulationState<NodeID, V>) -> [V.Scalar] {
        switch self {
        case .constant(let s):
            return simulation.nodeIds.map { _ in s }
        case .varied(let s):
            return simulation.nodeIds.map(s)
        }
    }
}

extension RadialForce.NodeRadius {
    @inlinable public func calculated(for simulation: SimulationState<NodeID, V>) -> [V.Scalar] {
        switch self {
        case .constant(let r):
            return simulation.nodeIds.map { _ in r }
        case .varied(let r):
            return simulation.nodeIds.map(r)
        }
    }
}

extension Simulation {
    @inlinable
    public func withRadialForce(
        center: V = .zero,
        radius: RadialForce<NodeID, V>.NodeRadius,
        strength: RadialForce<NodeID, V>.Strength = .constant(0.1)
    ) -> Simulation<
        NodeID, V, ForceTuple<NodeID, V, F, RadialForce<NodeID, V>>
    > where F.NodeID == NodeID, F.V == V {
        let f = RadialForce<NodeID, V>(center: center, radius: radius, strength: strength)
        //        f.bindSimulation(self.simulation)
        return with(f)
    }
}
