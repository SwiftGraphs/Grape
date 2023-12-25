public struct AnyGraphContentModifier: GraphContentModifier {

    @inlinable
    public func _prolog<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        storage._prolog(&context)
    }

    @inlinable
    public func _epilog<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        storage._epilog(&context)
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
