import SwiftUI

extension GraphContent {
    @inlinable
    public func foregroundStyle<S>(_ style: S) -> some GraphContent<NodeID> where S: ShapeStyle {
        return ModifiedGraphContent(self, GraphContentEffect.Shading(.style(style)))
    }

    @inlinable
    public func fill(_ shading: GraphicsContext.Shading) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GraphContentEffect.Shading(shading))
    }

    // @inlinable
    // public func fill(by value: some Hashable) -> some GraphContent<NodeID> {
    //     return ModifiedGraphContent(self, GraphContentEffect.Shading(.by(value)))
    // }

    @inlinable
    public func opacity(_ alpha: Double) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GraphContentEffect.Opacity(alpha))
    }

    @inlinable
    public func label(_ text: Text) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GraphContentEffect.Label(text))
    }

    @inlinable
    public func label(_ string: String) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GraphContentEffect.Label(Text(string)))
    }

    @inlinable
    public func stroke(
        _ color: Color,
        lineWidth: CGFloat = 1,
        lineCap: CGLineCap = .butt
    ) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(
            self, GraphContentEffect.Stroke(.color(color), lineWidth: lineWidth, lineCap: lineCap))
    }
}
