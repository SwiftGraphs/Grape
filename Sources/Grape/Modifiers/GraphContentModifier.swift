@_typeEraser(AnyGraphContentModifier)
public protocol GraphContentModifier {

    @inlinable
    func _into<NodeID: Hashable>(
        _ context: inout _GraphRenderingContext<NodeID>
    )

    @inlinable
    func _exit<NodeID: Hashable>(
        _ context: inout _GraphRenderingContext<NodeID>
    )

}
