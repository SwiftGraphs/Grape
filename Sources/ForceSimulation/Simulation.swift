public struct Simulation<NodeID, V, F>
where NodeID: Hashable, V: VectorLike, V.Scalar: SimulatableFloatingPoint, F: ForceProtocol {
    public var state: SimulationState<NodeID, V>
    @usableFromInline var force: F

    @inlinable
    public init(simulation: SimulationState<NodeID, V>, force: F) {
        self.state = simulation
        self.force = force
    }

    @inlinable
    public func with<NewForce: ForceProtocol>(_ f: NewForce) -> Simulation<
        NodeID, V, Force.ForceField<NodeID, V, F, NewForce>
    > where NewForce.NodeID == NodeID, NewForce.V == V, F.V == V, F.NodeID == NodeID {
        f.bindSimulation(self.state)
        return .init(
            simulation: self.state,
            force: Force.ForceField(self.force, f)
        )
    }

    /// Run the simulation for a number of iterations.
    /// Goes through all the forces created.
    /// The forces will call  `apply` then the positions and velocities will be modified.
    /// - Parameter iterationCount: Default to 1.
    @inlinable
    public func tick(iterationCount: UInt = 1) {
        for _ in 0..<iterationCount {
            state.alpha += (state.alphaTarget - state.alpha) * state.alphaDecay

            force.apply()

            for i in state.nodePositions.indices {
                if let fixation = state.nodeFixations[i] {
                    state.nodePositions[i] = fixation
                } else {
                    state.nodeVelocities[i] *= state.velocityDecay
                    state.nodePositions[i] += state.nodeVelocities[i]
                }
            }
        }
    }

    @inlinable public var nodePositions: [V] { state.nodePositions }
}

extension Simulation where F == Force.EmptyForce<NodeID, V> {
    @inlinable
    public init(
        nodeIds: [NodeID],
        alpha: V.Scalar = 1,
        alphaMin: V.Scalar = 1e-3,
        alphaDecay: V.Scalar = 2e-3,
        alphaTarget: V.Scalar = 0.0,
        velocityDecay: V.Scalar = 0.6,
        setInitialStatus getInitialPosition: (
            (NodeID) -> V
        )? = nil
    ) {
        self.state = SimulationState<NodeID, V>(
            nodeIds: nodeIds,
            alpha: alpha,
            alphaMin: alphaMin,
            alphaDecay: alphaDecay,
            alphaTarget: alphaTarget,
            velocityDecay: velocityDecay,
            setInitialStatus: getInitialPosition
        )
        self.force = Force.EmptyForce()
    }

}

public enum SimulationError: Error {
    case nodeNotFound
    case buildQuadTreeBeforeSimulationInitialized
}

#if canImport(simd)
    import simd

    public typealias Simulation2D<NodeID> = Simulation<
        NodeID, simd_double2, Force.EmptyForce<NodeID, simd_double2>
    > where NodeID: Hashable

    public typealias Simulation3D<NodeID> = Simulation<
        NodeID, simd_float3, Force.EmptyForce<NodeID, simd_float3>
    > where NodeID: Hashable

    public typealias SimulationState2D<NodeID> = SimulationState<NodeID, simd_double2> where NodeID: Hashable
    public typealias SimulationState3D<NodeID> = SimulationState<NodeID, simd_float3> where NodeID: Hashable

#endif
