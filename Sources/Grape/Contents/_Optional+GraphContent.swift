extension Optional where Wrapped: GraphContent {

    public typealias NodeID = Wrapped.NodeID
    
    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<Wrapped.NodeID>) {
        switch self {
        case .none:
            break
        case .some(let content):
            content._attachToGraphRenderingContext(&context)
        }
    }
}