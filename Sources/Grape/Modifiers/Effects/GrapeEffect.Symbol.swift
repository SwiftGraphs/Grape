import Charts
import SwiftUI

extension GraphContentEffect {
    @usableFromInline
    internal struct Symbol {
        @usableFromInline
        let shape: AnyShape

        @inlinable
        public init<S>(_ shape: S) where S: SwiftUI.Shape {
            self.shape = .init(shape)
        }
    }
}

extension GraphContentEffect.Symbol: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        let currentSize = context.states.currentSymbolSize ?? context.states.defaultSymbolSize
        context.states.symbolShape.append(
            shape.path(
                in: CGRect(
                    origin: CGPoint(x: -currentSize.width / 2, y: -currentSize.height / 2),
                    size: currentSize
                )
            )
        )
    }

    @inlinable
    public func _exit<NodeID>(_ context: inout _GraphRenderingContext<NodeID>)
    where NodeID: Hashable {
        context.states.symbolShape.removeLast()
    }
}
