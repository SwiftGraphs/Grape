import SwiftUI

extension GraphContentEffect {
    @usableFromInline
    internal struct Stroke {
        // @usableFromInline
        // let shading: GraphicsContext.Shading

        @usableFromInline
        let style: StrokeStyle
        
        @inlinable
        public init(
            // _ shading: GraphicsContext.Shading,
            _ style: StrokeStyle = StrokeStyle()
        ) {
            // self.shading = shading
            self.style = style
        }
    }
}


extension GraphContentEffect.Stroke: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        context.states.stroke.append(style)
    }

    @inlinable
    public func _exit<NodeID>(_ context: inout _GraphRenderingContext<NodeID>)
    where NodeID: Hashable {
        context.states.stroke.removeLast()
    }
}