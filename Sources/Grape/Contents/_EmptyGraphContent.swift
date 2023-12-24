@usableFromInline
struct _EmptyGraphContent<NodeID: Hashable>: GraphContent {
    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        
    }
}