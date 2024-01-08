public struct Series<NodeID, Data, Content>
where Data: RandomAccessCollection, Content: GraphContent<NodeID>, NodeID: Hashable {

    @usableFromInline
    let data: Data

    @usableFromInline
    let content: (Data.Element) -> Content

    @inlinable
    public init(
        _ data: Data,
        @GraphContentBuilder<NodeID> graphContent: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.content = graphContent
    }
}

extension Series: GraphContent {
    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        self.data.forEach { element in
            self.content(element)._attachToGraphRenderingContext(&context)
        }
    }
}
