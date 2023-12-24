public protocol GraphComponent<NodeID>: GraphContent {

    associatedtype Body: GraphContent<NodeID>

    @GraphContentBuilder<Body.NodeID>
    var body: Body { get }
}

extension GraphComponent {

    // public typealias NodeID = Body.NodeID

    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<Body.NodeID>) {
        body._attachToGraphRenderingContext(&context)
    }
}