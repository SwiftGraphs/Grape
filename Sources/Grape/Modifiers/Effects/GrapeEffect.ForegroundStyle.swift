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
        let storage: GraphicsContext.Shading

        @inlinable
        public init(_ storage: GraphicsContext.Shading) {
            self.storage = storage
        }
    }
}


extension GraphContentEffect.ForegroundStyle: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        context.states.shading.append(.style(style))
    }

    @inlinable
    public func _exit<NodeID>(_ context: inout _GraphRenderingContext<NodeID>) where NodeID : Hashable {
        context.states.shading.removeLast()
    }
}

extension GraphContentEffect.Shading: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        context.states.shading.append(storage)
    }

    @inlinable
    public func _exit<NodeID>(_ context: inout _GraphRenderingContext<NodeID>) where NodeID : Hashable {
        context.states.shading.removeLast()
    }
}