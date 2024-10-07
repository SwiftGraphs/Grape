@usableFromInline
struct AnyGraphContent<NodeID: Hashable>: GraphContent {

    @usableFromInline
    let storage: any GraphContent<NodeID>

    @inlinable
    init(_ storage: any GraphContent<NodeID>) {
        self.storage = storage
    }

    @inlinable
    func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        storage._attachToGraphRenderingContext(&context)
    }

}