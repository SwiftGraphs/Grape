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

//    @inlinable
//    internal var isRunning: Bool {
//        get {
//            _isRunning.wrappedValue
//        }
//        set {
//            _isRunning.wrappedValue = newValue
//        }
//    }

//    @usableFromInline
//    internal var _isRunning: Binding<Bool>

    // @inlinable
    // internal var modelTransform: ViewportTransform {
    //     get {
    //         _modelTransform.wrappedValue
    //     }
    //     set {
    //         _modelTransform.wrappedValue = newValue
    //     }
    // }

    @SealedForce2DBuilder
    @inlinable
    static public func defaulForce() -> [SealedForce2D.ForceEntry] {
        ManyBodyForce()
        LinkForce()
    }

    @inlinable
    public init(
        states: ForceDirectedGraphState = ForceDirectedGraphState(),
        ticksPerSecond: Double = 60.0,
        @GraphContentBuilder<NodeID> _ graph: () -> Content,
        @SealedForce2DBuilder force: () -> [SealedForce2D.ForceEntry] = Self.defaulForce,
        emittingNewNodesWithStates state: @escaping (NodeID) -> KineticState = { _ in
            .init(position: .zero)
        }
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
            emittingNewNodesWith: state,
            ticksPerSecond: ticksPerSecond
        )
        
    }

}