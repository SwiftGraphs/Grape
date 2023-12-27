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

    @usableFromInline
    internal struct Shading {
        @usableFromInline
        let storage: GraphicsContext.Shading

        @inlinable
        public init(_ storage: GraphicsContext.Shading) {
            self.storage = storage
        }
    }
}


extension GrapeEffect.ForegroundStyle: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        
    }
}

extension GrapeEffect.Shading: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        context.operations.append(.modifierBegin(AnyGraphContentModifier(erasing: self)))
    }
}