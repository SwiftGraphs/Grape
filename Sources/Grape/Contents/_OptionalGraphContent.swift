
@usableFromInline
struct _OptionalGraphContent<C>: GraphContent 
where C: GraphContent {
    public typealias NodeID = C.NodeID
    
    @usableFromInline
    let storage: C?

    @inlinable
    public init(
        _ storage: C?
    ) {
        self.storage = storage
    }

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        switch storage {
        case .none:
            break
        case .some(let content):
            content._attachToGraphRenderingContext(&context)
        }
    }
}