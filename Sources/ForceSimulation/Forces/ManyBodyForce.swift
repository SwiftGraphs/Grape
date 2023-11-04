extension Dimension {

    public struct ManyBodyForce: ForceProtocol {
        public func bind<S: SimulationProtocol>(_ simulation: S)
        where S.NodeID == NodeID, S.V == V {

        }

        public func apply() {

        }
    }

}
