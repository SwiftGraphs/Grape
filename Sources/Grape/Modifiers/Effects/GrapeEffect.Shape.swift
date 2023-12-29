import SwiftUI
extension GraphContentEffect {
    @usableFromInline
    internal struct Shape {
        @usableFromInline
        let path: Path

        @inlinable
        public init(_ path: Path) {
            self.path = path
        }
    }
}

extension GraphContentEffect.Shape: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        context.states.shape.append(path)
    }

    @inlinable
    public func _exit<NodeID>(_ context: inout _GraphRenderingContext<NodeID>)
    where NodeID: Hashable {
        context.states.shape.removeLast()
    }
}
