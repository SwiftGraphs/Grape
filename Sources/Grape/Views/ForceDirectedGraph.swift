import ForceSimulation
import SwiftUI

public struct ForceDirectedGraph<NodeID: Hashable, Content: GraphContent>
where NodeID == Content.NodeID {

    // public typealias NodeID = Content.NodeID

    @inlinable
    @Environment(\.self)
    internal var environment: EnvironmentValues

    @inlinable
    @Environment(\.graphForegroundScaleEnvironment)
    internal var graphForegroundScale

    @inlinable
    @Environment(\.colorScheme)
    internal var colorScheme

    @inlinable
    @Environment(\.colorSchemeContrast)
    internal var colorSchemeContrast

    // the copy of the graph context to be used for comparison in `onChange`
    // should be not used for rendering
    @usableFromInline
    internal let _graphRenderingContextShadow: _GraphRenderingContext<NodeID>

    @usableFromInline
    internal let _forceDescriptors: [SealedForce2D.ForceEntry]

    // // TBD: Some state to be retained when the graph is updated
    // @State
    // @inlinable
    // internal var clickCount = 0

    // @State
    @inlinable
    internal var model: ForceDirectedGraphModel<Content>
    {
        @storageRestrictions(initializes: _model)
        init(initialValue) {
            _model = .init(initialValue: initialValue)
        }
        get { _model.wrappedValue }
        set { _model.wrappedValue = newValue }
    }

    @usableFromInline
    internal var _model: State<ForceDirectedGraphModel<Content>>

    /// The default force to be applied to the graph
    ///
    /// - Returns: The default forces
    @SealedForce2DBuilder
    @inlinable
    static public func defaultForce() -> [SealedForce2D.ForceEntry] {
        ManyBodyForce()
        LinkForce()
    }

    /// Creates a force-directed graph view.
    ///
    /// This function creates a force-directed graph view with the given parameters.
    ///
    /// - Parameters:
    ///   - states: The initial state of the force-directed graph.
    ///   - ticksPerSecond: The number of ticks per second. Notice that this only determines the frequency of
    ///     the simulation updates, and the actual frame rate may be different.
    ///   - graph: The graph content. The `ForceDirectedGraph` will observe the changes of the graph content 
    ///     and try to update the elements with minimal changes across the parameter updates. 
    ///   - force: The forces to be applied to the graph.
    ///   - emittingNewNodesWithStates: Tells the simulation where to place the new nodes and provide their
    ///     initial kinetic states. This is only applied on the new nodes that is not seen before when the
    ///     graph is created (or updated).
    @inlinable
    @MainActor
    public init(
        states: ForceDirectedGraphState = ForceDirectedGraphState(),
        ticksPerSecond: Double = 60.0,
        @GraphContentBuilder<NodeID> graph: () -> Content,
        @SealedForce2DBuilder force: () -> [SealedForce2D.ForceEntry] = Self.defaultForce,
        emittingNewNodesWithStates: @escaping (NodeID) -> KineticState = defaultKineticStateProvider
    ) {

        var gctx = _GraphRenderingContext<NodeID>()
        graph()._attachToGraphRenderingContext(&gctx)

        self._graphRenderingContextShadow = gctx

        self._forceDescriptors = force()

        let force = SealedForce2D(self._forceDescriptors)
        self.model = .init(
            gctx,
            force,
            stateMixin: states,
            emittingNewNodesWith: emittingNewNodesWithStates,
            ticksPerSecond: ticksPerSecond
        )

    }

    @inlinable
    public static func defaultKineticStateProvider(nodeID: NodeID) -> KineticState {
        .init(position: .zero)
    }

}
