extension Dimension {
    public final class CenterForce: ForceProtocol {

        @usableFromInline
        weak var state: PhysicalState?

        public var center: V
        public var strength: V.Scalar

        @inlinable
        public func bind<S: SimulationProtocol>(_ simulation: S)
        where S.NodeID == NodeID, S.V == V {
            self.state = simulation.state
        }

        init(center: V, strength: V.Scalar) {
            self.center = center
            self.strength = strength
        }

        public func apply() {
            guard let state = self.state else { return }

            var meanPosition = V.zero
            for n in state.nodePositions {
                meanPosition += n  //.position
            }
            let delta = meanPosition * (self.strength / V.Scalar(state.nodePositions.count))

            for i in state.nodePositions.indices {
                state.nodePositions[i] -= delta
            }
        }

        static public func create(from descriptor: Center<V>) -> CenterForce {
            return CenterForce(center: descriptor.center, strength: descriptor.strength)
        }
    }

}
