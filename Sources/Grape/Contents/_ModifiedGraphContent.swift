public protocol GraphContentModifier {

}

public struct _ModifiedGraphContent<C, M> where C: GraphContent, M: GraphContentModifier {

    @usableFromInline
    let content: C

    @usableFromInline
    let modifier: M

    @inlinable
    public init(
        _ content: C,
        _ modifier: M
    ) {
        self.content = content
        self.modifier = modifier
    }
}

extension _ModifiedGraphContent: GraphContent {
    public typealias NodeID = C.NodeID

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        content._attachToGraphRenderingContext(&context)
    }
}

public struct GraphContentOpacitityModifier: GraphContentModifier {
    @usableFromInline
    let value: Double

    @inlinable
    public init(_ value: Double) {
        self.value = value
    }
}
