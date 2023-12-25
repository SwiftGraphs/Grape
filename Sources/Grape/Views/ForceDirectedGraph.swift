import SwiftUI

public struct ForceDirectedGraph<NodeID: Hashable> {
 
    // the copy of the graph context to be used for comparison in `onChange`
    // should be not used for rendering
    let _graphRenderingContextShadow: _GraphRenderingContext<NodeID> 

    // Some state to be retained when the graph is updated
    @State 
    var clickCount = 0

    @State
    var model: ForceDirectedGraphModel<NodeID>
    
    @Binding
    var isRunning: Bool

    public init(
        _ isRunning: Binding<Bool> = .constant(true),
        @GraphContentBuilder<NodeID> _ graph: () -> some GraphContent<NodeID>
    ) {
        var gctx = _GraphRenderingContext<NodeID>()
        graph()._attachToGraphRenderingContext(&gctx)
        self._graphRenderingContextShadow = gctx
        self._isRunning = isRunning
        self.model = ForceDirectedGraphModel(gctx)
    }
}

public extension ForceDirectedGraph {
    func onTicked(
        action: @escaping (KeyFrame) -> Void
    ) -> Self {
        self.model._onTicked = action
        return self
    }
}