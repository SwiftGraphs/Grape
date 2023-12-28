import SwiftUI

extension GrapeEffect {
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


extension GrapeEffect.Stroke: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        context.operations.append(.modifierBegin(AnyGraphContentModifier(erasing: self)))
    }
}