extension GrapeEffect {
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

extension GrapeEffect.Opacity: GraphContentModifier {
    @inlinable
    public func _prolog<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        // context.opacityStack.append(value)
    }

    @inlinable
    public func _epilog<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        // context.opacityStack.removeLast()
    }
}
