extension Dimension {

    public struct Simulation<CompositedForce>: SimulationProtocol
    where CompositedForce: ForceProtocol, CompositedForce.NodeID == NodeID, CompositedForce.V == V {

        public var nodeIds: [NodeID]
        public var state: PhysicalState
        public var field: CompositedForce

        init(
            nodeIds: [NodeID],
            @ForceBuilder _ buildForceDescriptor: () -> CompositedForce
        ) {
            self.field = buildForceDescriptor()
            self.nodeIds = nodeIds
            self.state = PhysicalState()
        }
    }

}

extension Dimension {
    public final class PhysicalState {
        var nodeVelocities: [V]
        var nodePositions: [V]
        var nodeFixations: [V?]

        init() {
            self.nodeVelocities = []
            self.nodePositions = []
            self.nodeFixations = []
        }
    }
}