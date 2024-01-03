@usableFromInline
struct _ArrayGraphContent<C>: GraphContent 
where C: GraphContent {
    public typealias NodeID = C.NodeID

    @usableFromInline
    let storage: [C]

    @inlinable
    public init(
        _ storage: [C]
    ) {
        self.storage = storage
    }

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        for content in storage {
            content._attachToGraphRenderingContext(&context)
        }
    }
}