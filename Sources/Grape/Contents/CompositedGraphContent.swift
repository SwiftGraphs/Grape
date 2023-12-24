public protocol GraphComponent: GraphContent {

    associatedtype Body: GraphContent<NodeID>
    
    @GraphContentBuilder<NodeID>
    var body: Body { get }
}

extension GraphComponent {
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        body._attachToGraphRenderingContext(&context)
    }
}