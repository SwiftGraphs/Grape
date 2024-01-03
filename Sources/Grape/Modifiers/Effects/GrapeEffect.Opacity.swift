extension GraphContentEffect {
    @usableFromInline
    internal struct Opacity {
        @usableFromInline
        let value: Double

        @inlinable
        public init(_ value: Double) {
            self.value = value
        }
    }
}

extension GraphContentEffect.Opacity: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        context.states.opacity.append(value)
    }

    @inlinable
    public func _exit<NodeID>(_ context: inout _GraphRenderingContext<NodeID>)
    where NodeID: Hashable {
        context.states.opacity.removeLast()
    }
}
