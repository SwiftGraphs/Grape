import ForceSimulation
import SwiftUI

public struct ForceDirectedGraph<NodeID: Hashable> {

    // the copy of the graph context to be used for comparison in `onChange`
    // should be not used for rendering
    @usableFromInline
    let _graphRenderingContextShadow: _GraphRenderingContext<NodeID>

    @usableFromInline
    let _forceDescriptors: [SealedForce2D.ForceEntry]

    // TBD: Some state to be retained when the graph is updated
    @State
    @inlinable
    var clickCount = 0

    // @State
    @inlinable
    var model: ForceDirectedGraphModel<NodeID>
    {
        @storageRestrictions(initializes: _model)
        init(initialValue) { _model = .init(initialValue: initialValue) }
        get { _model.wrappedValue }
        set { _model.wrappedValue = newValue }
    }

    @usableFromInline
    var _model: State<ForceDirectedGraphModel<NodeID>>

    @inlinable
    var isRunning: Bool {
        get {
            _isRunning.wrappedValue
        }
        set {
            _isRunning.wrappedValue = newValue
        }
    }

    @usableFromInline
    var _isRunning: Binding<Bool>

    @inlinable
    public init(
        _ _isRunning: Binding<Bool> = .constant(true),
        @GraphContentBuilder<NodeID> _ graph: () -> some GraphContent<NodeID>,
        @SealedForce2DBuilder force: () -> [SealedForce2D.ForceEntry] = { [] }
    ) {
        var gctx = _GraphRenderingContext<NodeID>()
        graph()._attachToGraphRenderingContext(&gctx)
        self._graphRenderingContextShadow = gctx
        self._isRunning = _isRunning

        self._forceDescriptors = force()
        let force = SealedForce2D(self._forceDescriptors)
        self.model = .init(gctx, force)
    }
}

extension ForceDirectedGraph {
    @inlinable
    public func onTicked(
        action: @escaping (KeyFrame) -> Void
    ) -> Self {
        self.model._onTicked = action
        return self
    }
}
