public struct ForceDirectedGraph<NodeID: Hashable> {
    @usableFromInline
    let graphContext: _GraphRenderingContext<NodeID>

    @inlinable
    public init(
        @GraphContentBuilder<NodeID> _ buildGraphContent: () -> some GraphContent<NodeID>
    ) {
        var graphContext = _GraphRenderingContext<NodeID>()
        buildGraphContent()._attachToGraphRenderingContext(&graphContext)
        self.graphContext = graphContext
    }
}
