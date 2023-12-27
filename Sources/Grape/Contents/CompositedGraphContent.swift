public protocol GraphComponent<NodeID>: GraphContent {

    associatedtype Body: GraphContent<NodeID>
    
    @inlinable
    @GraphContentBuilder<Body.NodeID>
    var body: Body { get }
}

extension GraphComponent {

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<Body.NodeID>)
    {
        body._attachToGraphRenderingContext(&context)
    }
}
