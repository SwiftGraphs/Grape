public struct Simulation<NodeID, V, F>
where NodeID: Hashable, V: VectorLike, V.Scalar: SimulatableFloatingPoint, F: ForceProtocol {
    @usableFromInline var simulation: SimulationState<NodeID, V>
    @usableFromInline var force: F

    @inlinable
    public init(simulation: SimulationState<NodeID, V>, force: F) {
        self.simulation = simulation
        self.force = force
    }

    @inlinable
    public func with<NewForce: ForceProtocol>(_ f: NewForce) -> Simulation<
        NodeID, V, ForceTuple<NodeID, V, F, NewForce>
    > where NewForce.NodeID == NodeID, NewForce.V == V, F.V == V, F.NodeID == NodeID {
        f.bindSimulation(self.simulation)
        return .init(
            simulation: self.simulation,
            force: ForceTuple(self.force, f)
        )
    }

    /// Run the simulation for a number of iterations.
    /// Goes through all the forces created.
    /// The forces will call  `apply` then the positions and velocities will be modified.
    /// - Parameter iterationCount: Default to 1.
    @inlinable
    public func tick(iterationCount: UInt = 1) {
        for _ in 0..<iterationCount {
            simulation.alpha += (simulation.alphaTarget - simulation.alpha) * simulation.alphaDecay

            force.apply()

            for i in simulation.nodePositions.indices {
                if let fixation = simulation.nodeFixations[i] {
                    simulation.nodePositions[i] = fixation
                } else {
                    simulation.nodeVelocities[i] *= simulation.velocityDecay
                    simulation.nodePositions[i] += simulation.nodeVelocities[i]
                }
            }
        }
    }

    @inlinable public var nodePositions: [V] { simulation.nodePositions }
}

extension Simulation where F == EmptyForce<NodeID, V> {
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
        self.simulation = SimulationState<NodeID, V>(
            nodeIds: nodeIds,
            alpha: alpha,
            alphaMin: alphaMin,
            alphaDecay: alphaDecay,
            alphaTarget: alphaTarget,
            velocityDecay: velocityDecay,
            setInitialStatus: getInitialPosition
        )
        self.force = EmptyForce()
    }

}

// extension Simulation {
//     @inlinable
//     static func create<Vector>(
//         nodeIds: [NodeID],
//         alpha: Vector.Scalar = 1,
//         alphaMin: Vector.Scalar = 1e-3,
//         alphaDecay: Vector.Scalar = 2e-3,
//         alphaTarget: Vector.Scalar = 0.0,
//         velocityDecay: Vector.Scalar = 0.6,
//         setInitialStatus getInitialPosition: (
//             (NodeID) -> Vector
//         )? = nil
//     ) -> Simulation<NodeID, Vector, EmptyForce<NodeID, Vector>> {
//         return .init(
//             simulation: SimulationState<NodeID, Vector>(
//                 nodeIds: nodeIds,
//                 alpha: alpha,
//                 alphaMin: alphaMin,
//                 alphaDecay: alphaDecay,
//                 alphaTarget: alphaTarget,
//                 velocityDecay: velocityDecay,
//                 setInitialStatus: getInitialPosition
//             ),
//             force: EmptyForce()
//         )
//     }
// }

public enum SimulationError: Error {
    case nodeNotFound
    case buildQuadTreeBeforeSimulationInitialized
}

#if canImport(simd)
    import simd

    public typealias Simulation2D<NodeID> = Simulation<
        NodeID, simd_double2, EmptyForce<NodeID, simd_double2>
    > where NodeID: Hashable
    public typealias Simulation3D<NodeID> = Simulation<
        NodeID, simd_float3, EmptyForce<NodeID, simd_float3>
    > where NodeID: Hashable

#endif
