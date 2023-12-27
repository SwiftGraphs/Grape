public struct AnyGraphContentModifier: GraphContentModifier {

    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        storage._into(&context)
    }

    @inlinable
    public func _exit<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        storage._exit(&context)
    }

    @usableFromInline
    let storage: any GraphContentModifier

    @inlinable
    public init<T: GraphContentModifier>(erasing: T) {
        self.storage = erasing
    }

    @inlinable
    public static func == (lhs: AnyGraphContentModifier, rhs: AnyGraphContentModifier) -> Bool {
        return false
    }
}
