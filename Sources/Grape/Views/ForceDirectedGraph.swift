import SwiftUI

class GCRBox<NodeID: Hashable> {
    var graphContext: _GraphRenderingContext<NodeID>

    init(_ graphContext: _GraphRenderingContext<NodeID>) {
        self.graphContext = graphContext
    }
}

public struct ForceDirectedGraph<NodeID: Hashable> {

    let box: GCRBox<NodeID>

    var graphContext: _GraphRenderingContext<NodeID> {
        box.graphContext
    }

    @State var clickCount = 0

    public init(
        @GraphContentBuilder<NodeID> _ graph: () -> some GraphContent<NodeID>
    ) {
        var gctx = _GraphRenderingContext<NodeID>()
        graph()._attachToGraphRenderingContext(&gctx)
        print(gctx.nodes.count)
        self.box = GCRBox(gctx)
    }
}
