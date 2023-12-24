import SwiftUI

class GCRBox<NodeID: Hashable> {
    var graphContext: _GraphRenderingContext<NodeID>

    init(_ graphContext: _GraphRenderingContext<NodeID>) {
        self.graphContext = graphContext
    }
}


class ForceDirectedGraphModel<NodeID: Hashable>: ObservableObject {
    init() {

    }
}

public struct ForceDirectedGraph<NodeID: Hashable> {

    var graphContext: _GraphRenderingContext<NodeID>

    // Some state to be retained when the graph is updated
    @State var clickCount = 0

    @State var changeMessage = "N/A"

    public init(
        @GraphContentBuilder<NodeID> _ graph: () -> some GraphContent<NodeID>
    ) {
        var gctx = _GraphRenderingContext<NodeID>()
        graph()._attachToGraphRenderingContext(&gctx)
        self.graphContext = gctx
    }
}
