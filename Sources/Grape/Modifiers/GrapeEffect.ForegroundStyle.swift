import SwiftUI

extension GrapeEffect {
    @usableFromInline
    internal struct ForegroundStyle<S> where S: ShapeStyle {
        @usableFromInline
        let style: S

        @inlinable
        public init(_ style: S) {
            self.style = style
        }
    }
}


extension GrapeEffect.ForegroundStyle: GraphContentModifier {
    @inlinable
    public func _prolog<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        
    }

    @inlinable
    public func _epilog<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        
    }
}