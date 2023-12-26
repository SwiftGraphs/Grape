import SwiftUI
import ForceSimulation

public struct ForceDirectedGraph<NodeID: Hashable> {
 
    // the copy of the graph context to be used for comparison in `onChange`
    // should be not used for rendering
    @usableFromInline
    let _graphRenderingContextShadow: _GraphRenderingContext<NodeID> 

    // TBD: Some state to be retained when the graph is updated
    @State
    @inlinable
    var clickCount = 0

    @State
    @inlinable
    var model: ForceDirectedGraphModel<NodeID>
    
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
        self.model = ForceDirectedGraphModel(
            gctx,
            SealedForce2D(force())
        )
    }
}

public extension ForceDirectedGraph {
    @inlinable
    func onTicked(
        action: @escaping (KeyFrame) -> Void
    ) -> Self {
        self.model._onTicked = action
        return self
    }
}
