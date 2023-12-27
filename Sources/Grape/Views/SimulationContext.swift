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
        _ nodeIndexLookup: consuming [NodeID: Int]
    ) {
        self.storage = consume storage
        self.nodeIndexLookup = consume nodeIndexLookup
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
            uniqueKeysWithValues: nodes.enumerated().map {
                ($0.element.id, $0.offset)
            }
        )

        let links = graphRenderingContext.edges.map {
            EdgeID<Int>(
                source: nodeIndexLookup[$0.id.source]!,
                target: nodeIndexLookup[$0.id.target]!
            )
        }
        return .init(
            .init(
                nodeCount: nodes.count,
                links: consume links,
                forceField: consume forceField
            ),
            consume nodeIndexLookup
        )
    }

    /// reuse the same simulation context for new graph
    @inlinable
    public mutating func revive(
        for newContext: _GraphRenderingContext<NodeID>,
        with newForceField: consuming ForceField,
        emittingNewNodesFrom position: (NodeID, Kinetics2D) -> Vector = { _, _ in .zero },
        emittingNewNodesWith fixation: (NodeID, Kinetics2D) -> Vector? = { _, _ in nil }
    ) {
        let newNodes = newContext.nodes

        let newNodeIndexLookup = Dictionary(
            uniqueKeysWithValues: newNodes.enumerated().map {
                ($0.element.id, $0.offset)
            }
        )

        let newLinks = newContext.edges.map {
            EdgeID<Int>(
                source: newNodeIndexLookup[$0.id.source]!,
                target: newNodeIndexLookup[$0.id.target]!
            )
        }
        
        let newPosition = newNodes.map {
            if let index = self.nodeIndexLookup[$0.id] {
                return storage.kinetics.position[index]
            }
            else {
                return position($0.id, storage.kinetics)
            }
        }
        

        let newVelocity = newNodes.map {
            if let index = self.nodeIndexLookup[$0.id] {
                return storage.kinetics.velocity[index]
            }
            else {
                return .zero
            }
        }

        let newFixation = newNodes.map {
            if let index = self.nodeIndexLookup[$0.id] {
                return storage.kinetics.fixation[index]
            }
            else {
                return fixation($0.id, storage.kinetics)
            }
        }

        let newStorage = Simulation2D<SealedForce2D>(
            nodeCount: newNodes.count,
            links: consume newLinks,
            forceField: consume newForceField,
            position: consume newPosition,
            velocity: consume newVelocity,
            fixation: consume newFixation
        )

        self = .init(
            consume newStorage,
            consume newNodeIndexLookup
        )
    }
}
