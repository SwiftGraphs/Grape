@_typeEraser(AnyGraphContentModifier) 
public protocol GraphContentModifier {

    @inlinable
    func _prolog<NodeID: Hashable>(
        _ context: inout _GraphRenderingContext<NodeID>
    )

    @inlinable
    func _epilog<NodeID: Hashable>(
        _ context: inout _GraphRenderingContext<NodeID>
    )

}
