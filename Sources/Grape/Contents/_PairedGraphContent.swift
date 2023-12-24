public struct _PairedGraphContent<C1, C2, NodeID>: GraphContent 
where C1: GraphContent, C2: GraphContent, NodeID: Hashable, C1.NodeID == NodeID, C2.NodeID == NodeID {
    @usableFromInline
    let first: C1

    @usableFromInline
    let second: C2
    
    @inlinable
    public init(_ first: C1, _ second: C2) {
        self.first = first
        self.second = second
    }

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        first._attachToGraphRenderingContext(&context)
        second._attachToGraphRenderingContext(&context)
    }
}