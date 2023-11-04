extension Force {

    /// A force that moves nodes to a target position.
    /// Center force is relatively fast, the complexity is `O(n)`,
    /// where `n` is the number of nodes.
    /// See [Position Force - D3](https://d3js.org/d3-force/position).
    final public class DirectionForce<NodeID, V>: ForceProtocol
    where NodeID: Hashable, V: VectorLike, V.Scalar: SimulatableFloatingPoint {

        public enum Direction {
            case x
            case y
            case entryOfVector(Int)
        }
        public enum Strength {
            case constant(V.Scalar)
            case varied((NodeID) -> V.Scalar)
        }

        public enum TargetOnDirection {
            case constant(V.Scalar)
            case varied((NodeID) -> V.Scalar)
        }

        public var strength: Strength
        public var direction: Int
        public var calculatedStrength: [V.Scalar] = []
        public var targetOnDirection: TargetOnDirection
        public var calculatedTargetOnDirection: [V.Scalar] = []

        @inlinable internal init(
            direction: Direction, targetOnDirection: TargetOnDirection,
            strength: Strength = .constant(1.0)
        ) {
            self.strength = strength
            self.direction = direction.lane
            self.targetOnDirection = targetOnDirection
        }

        @usableFromInline weak var simulation: SimulationState<NodeID, V>?

        @inlinable
        public func bindSimulation(_ simulation: SimulationState<NodeID, V>?) {
            self.simulation = simulation
            guard let sim = self.simulation else { return }
            self.calculatedStrength = strength.calculated(for: sim)
            self.calculatedTargetOnDirection = targetOnDirection.calculated(for: sim)

        }

        @inlinable
        public func apply() {
            guard let sim = self.simulation else { return }
            let alpha = sim.alpha
            let lane = self.direction
            for i in sim.nodePositions.indices {
                sim.nodeVelocities[i][lane] +=
                    (self.calculatedTargetOnDirection[i] - sim.nodePositions[i][lane])
                    * self.calculatedStrength[i] * alpha
            }
        }
    }

}
/// Create a direction force that moves nodes to a target position.
/// Center force is relatively fast, the complexity is `O(n)`,
/// where `n` is the number of nodes.
/// See [Position Force - D3](https://d3js.org/d3-force/position).
// @discardableResult
// @inlinable public func withPositionForce(
//     direction: DirectionForce.Direction,
//     targetOnDirection: DirectionForce.TargetOnDirection,
//     strength: DirectionForce.Strength = .constant(1.0)
// ) -> DirectionForce {
//     let force = DirectionForce(
//         direction: direction,
//         targetOnDirection: targetOnDirection,
//         strength: strength
//     )
//     force.simulation = self
//     self.forces.append(force)
//     return force
// }

extension Force.DirectionForce.Strength {
    @inlinable public func calculated(for simulation: SimulationState<NodeID, V>) -> [V.Scalar] {
        switch self {
        case .constant(let value):
            return Array(repeating: value, count: simulation.nodeIds.count)
        case .varied(let getter):
            return simulation.nodeIds.map(getter)
        }
    }
}

extension Force.DirectionForce.TargetOnDirection {
    @inlinable public func calculated(for simulation: SimulationState<NodeID, V>) -> [V.Scalar] {
        switch self {
        case .constant(let value):
            return Array(repeating: value, count: simulation.nodeIds.count)
        case .varied(let getter):
            return simulation.nodeIds.map(getter)
        }
    }
}

extension Force.DirectionForce.Direction {
    @inlinable var lane: Int {
        switch self {
        case .x: return 0
        case .y: return 1
        case .entryOfVector(let i): return i
        }
    }
}
extension Simulation {
    @inlinable
    func withDirectionForce(
        direction: Force.DirectionForce<NodeID, V>.Direction,
        targetOnDirection: Force.DirectionForce<NodeID, V>.TargetOnDirection,
        strength: Force.DirectionForce<NodeID, V>.Strength = .constant(1.0)
    ) -> Simulation<
        NodeID, V, Force.ForceField<NodeID, V, F, Force.DirectionForce<NodeID, V>>
    > where F.NodeID == NodeID, F.V == V {
        let f = Force.DirectionForce<NodeID, V>(
            direction: direction,
            targetOnDirection: targetOnDirection,
            strength: strength
        )
        //        f.bindSimulation(self.simulation)
        return with(f)
    }
}
