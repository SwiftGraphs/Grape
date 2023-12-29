import SwiftUI

extension GraphContentEffect {
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
        let shading: GraphicsContext.Shading

        @inlinable
        public init(_ shading: GraphicsContext.Shading) {
            self.shading = shading
        }
    }
}


extension GraphContentEffect.ForegroundStyle: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        let shading: GraphicsContext.Shading = .style(style)
        context.states.shading.append(shading)
        // context.operations.append(.updateShading(shading))
    }

    @inlinable
    public func _exit<NodeID>(_ context: inout _GraphRenderingContext<NodeID>) where NodeID : Hashable {
        context.states.shading.removeLast()
        // context.operations.append(
        //     .updateShading(context.states.currentShading)
        // )
    }
}

extension GraphContentEffect.Shading: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        context.states.shading.append(shading)
    }

    @inlinable
    public func _exit<NodeID>(_ context: inout _GraphRenderingContext<NodeID>) where NodeID : Hashable {
        context.states.shading.removeLast()
    }
}