import ForceSimulation

@usableFromInline
internal struct SimulationContext<NodeID: Hashable> {

    public typealias Vector = ForceField.Vector
    public typealias ForceField = SealedForce2D



    @usableFromInline
    internal var storage: Simulation2D<ForceField>

    @usableFromInline
    internal var nodeIndexLookup: [NodeID: Int]


    @inlinable
    internal init(
        _ storage: consuming Simulation2D<ForceField>,
        nodeIndexLookup: consuming [NodeID: Int]
    ) {
        self.storage = storage
        self.nodeIndexLookup = nodeIndexLookup
    }
}

extension SimulationContext {
    @inlinable
    public static func create(
        for graphRenderingContext: _GraphRenderingContext<NodeID>,
        with forceField: consuming ForceField
    ) -> Self {
        let nodes = graphRenderingContext.nodes

        let nodeIndexLookup = Dictionary(
            uniqueKeysWithValues: nodes.enumerated().map { ($0.element.id, $0.offset) })

        let links = graphRenderingContext.edges.map {
            EdgeID<Int>(
                source: nodeIndexLookup[$0.id.source]!, target: nodeIndexLookup[$0.id.target]!)
        }
        return .init(
            .init(
                nodeCount: nodes.count,
                links: consume links,
                forceField: consume forceField
            ),
            nodeIndexLookup: consume nodeIndexLookup
        )
    }

    /// reuse the same simulation context for new graph
    @inlinable
    public func revive(
        for graphRenderingContext: _GraphRenderingContext<NodeID>,
        with forceField: consuming ForceField
    ) {

    }
}
