import SwiftUI

extension GraphContentEffect {
    @usableFromInline
    internal struct SymbolSize {
        @usableFromInline
        let size: CGSize

        @inlinable
        public init(_ size: CGSize) {
            self.size = size
        }
    }
}

extension GraphContentEffect.SymbolSize: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        context.states.symbolSize.append(size)
    }

    @inlinable
    public func _exit<NodeID>(_ context: inout _GraphRenderingContext<NodeID>)
    where NodeID: Hashable {
        context.states.symbolSize.removeLast()
    }
}
