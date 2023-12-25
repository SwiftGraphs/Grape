import ForceSimulation

@usableFromInline
struct SimulationContext<NodeID: Hashable> {
    @usableFromInline
    var storage: Simulation2D<SealedForce2D>

    public typealias Vector = SealedForce2D.Vector

    @inlinable
    public init(
        nodeCount: Int,
        links: [EdgeID<Int>],
        forceField: consuming SealedForce2D,
        initialAlpha: Vector.Scalar = 1,
        alphaMin: Vector.Scalar = 1e-3,
        alphaDecay: Vector.Scalar = 2e-3,
        alphaTarget: Vector.Scalar = 0.0,
        velocityDecay: Vector.Scalar = 0.6
    ) {
        self.storage = .init(
            nodeCount: nodeCount,
            links: links,
            forceField: forceField,
            initialAlpha: initialAlpha,
            alphaMin: alphaMin,
            alphaDecay: alphaDecay,
            alphaTarget: alphaTarget,
            velocityDecay: velocityDecay
        )
    }
}
