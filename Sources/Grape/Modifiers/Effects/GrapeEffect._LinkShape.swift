import SwiftUI
extension GraphContentEffect {
    @usableFromInline
    internal struct _LinkShape {
        @usableFromInline
        let storage: any LinkShape

        @inlinable
        public init(_ path: some LinkShape) {
            self.storage = path
        }
    }
}

extension GraphContentEffect._LinkShape: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        context.states.linkShape.append(storage)
    }

    @inlinable
    public func _exit<NodeID>(_ context: inout _GraphRenderingContext<NodeID>)
    where NodeID: Hashable {
        context.states.linkShape.removeLast()
    }
}
