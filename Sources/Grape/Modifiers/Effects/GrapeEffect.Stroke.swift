import SwiftUI

extension GraphContentEffect {
    @usableFromInline
    internal struct Stroke {
        @usableFromInline
        let shading: GraphicsContext.Shading

        @usableFromInline
        let lineWidth: CGFloat

        @usableFromInline
        let lineCap: CGLineCap

        @usableFromInline
        let lineJoin: CGLineJoin

        @usableFromInline
        let miterLimit: CGFloat

        @usableFromInline
        let dashPhase: CGFloat
        
        @inlinable
        public init(
            _ shading: GraphicsContext.Shading,
            lineWidth: CGFloat = 1,
            lineCap: CGLineCap = .butt,
            lineJoin: CGLineJoin = .miter,
            miterLimit: CGFloat = 10,
            dashPhase: CGFloat = 0
        ) {
            self.shading = shading
            self.lineWidth = lineWidth
            self.lineCap = lineCap
            self.lineJoin = lineJoin
            self.miterLimit = miterLimit
            self.dashPhase = dashPhase
        }
    }
}


extension GraphContentEffect.Stroke: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        context.states.stroke.append(self)
        context.operations.append(.updateStroke(self))
    }

    @inlinable
    public func _exit<NodeID>(_ context: inout _GraphRenderingContext<NodeID>)
    where NodeID: Hashable {
        context.states.stroke.removeLast()
        context.operations.append(
            .updateStroke(context.states.currentStroke)
        )
    }
}