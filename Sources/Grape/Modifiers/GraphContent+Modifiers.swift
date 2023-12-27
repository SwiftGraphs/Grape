import SwiftUI
extension GraphContent {
    @inlinable
    public func foregroundStyle<S>(_ style: S) -> some GraphContent<NodeID> where S: ShapeStyle {
        return ModifiedGraphContent(self, GrapeEffect.Shading(.style(style)))
    }

    @inlinable
    public func fill(_ value: GraphicsContext.Shading) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GrapeEffect.Shading(value))
    }

    @inlinable
    public func opacity(_ value: Double) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GrapeEffect.Opacity(value))
    }
}