struct _ConditionalGraphContent<C1, C2, NodeID>: GraphContent 
where C1: GraphContent, C2: GraphContent, NodeID: Hashable, C1.NodeID == NodeID, C2.NodeID == NodeID {
    @usableFromInline
    enum Storage {
        case trueContent(C1)
        case falseContent(C2)
    }

    @usableFromInline
    let storage: Storage
    
    @inlinable
    public init(
        _ storage: Storage
    ) {
        self.storage = storage
    }

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        switch storage {
        case .trueContent(let content):
            content._attachToGraphRenderingContext(&context)
        case .falseContent(let content):
            content._attachToGraphRenderingContext(&context)
        }
    }
}