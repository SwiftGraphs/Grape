import SwiftUI

extension GraphContent {
    @inlinable
    public func foregroundStyle<S>(_ style: S) -> some GraphContent<NodeID> where S: ShapeStyle {
        return ModifiedGraphContent(self, GrapeEffect.Shading(.style(style)))
    }

    @inlinable
    public func fill(_ shading: GraphicsContext.Shading) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GrapeEffect.Shading(shading))
    }

    @inlinable
    public func opacity(_ alpha: Double) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GrapeEffect.Opacity(alpha))
    }

    @inlinable
    public func label(_ text: Text) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GrapeEffect.Label(text))
    }

    @inlinable
    public func label(_ string: String) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GrapeEffect.Label(Text(string)))
    }

    @inlinable
    public func stroke(
        _ color: Color,
        lineWidth: CGFloat = 1,
        lineCap: CGLineCap = .butt
    ) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(
            self, GrapeEffect.Stroke(.color(color), lineWidth: lineWidth, lineCap: lineCap))
    }
}
