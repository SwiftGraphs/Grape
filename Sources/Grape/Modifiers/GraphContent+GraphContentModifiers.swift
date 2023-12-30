import Charts
import SwiftUI

extension GraphContent {
    @inlinable
    @_disfavoredOverload
    public func foregroundStyle<S>(_ style: S) -> some GraphContent<NodeID>
    where S: SwiftUI.ShapeStyle {
        return ModifiedGraphContent(self, GraphContentEffect.Shading(.style(style)))
    }

    @inlinable
    public func foregroundStyle(_ color: Color) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GraphContentEffect.Shading(.color(color)))
    }

    @inlinable
    @_disfavoredOverload
    public func symbol<S>(_ shape: S) -> some GraphContent<NodeID> where S: SwiftUI.Shape {
        return ModifiedGraphContent(self, GraphContentEffect.Symbol(shape))
    }

    @inlinable
    public func symbol(_ shape: BasicChartSymbolShape) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GraphContentEffect.Symbol(shape))
    }

    @inlinable
    public func symbolSize(_ size: CGSize) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GraphContentEffect.SymbolSize(size))
    }

    @inlinable
    public func symbolSize(_ radius: CGFloat) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(
            self,
            GraphContentEffect.SymbolSize(
                CGSize(width: radius * 2, height: radius * 2)
            ))
    }

    @inlinable
    @available(*, deprecated, message: "use foregroundStyle(_:)")
    public func fill(_ shading: GraphicsContext.Shading) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GraphContentEffect.Shading(shading))
    }

    @inlinable
    public func label(_ text: Text, alignment: Alignment) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GraphContentEffect.Label(text))
    }

    @inlinable
    public func label(_ string: String, alignment: Alignment) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GraphContentEffect.Label(Text(string)))
    }

    @inlinable
    public func label(_ alignment: Alignment, @ViewBuilder _ text: () -> Text) -> some GraphContent<
        NodeID
    > {
        return ModifiedGraphContent(self, GraphContentEffect.Label(text()))
    }

    @inlinable
    public func stroke(
        lineWidth: CGFloat = 1,
        lineCap: CGLineCap = .butt,
        lineJoin: CGLineJoin = .miter,
        miterLimit: CGFloat = 10,
        dash: [CGFloat] = [CGFloat](),
        dashPhase: CGFloat = 0
    ) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(
            self,
            GraphContentEffect.Stroke(
                .init(
                    lineWidth: lineWidth,
                    lineCap: lineCap,
                    lineJoin: lineJoin,
                    miterLimit: miterLimit,
                    dash: dash,
                    dashPhase: dashPhase
                )
            ))
    }

    @inlinable
    @_disfavoredOverload
    public func stroke<S>(
        _ strokeStyle: StrokeStyle
    ) -> some GraphContent<NodeID> where S: ShapeStyle {
        return ModifiedGraphContent(
            self, GraphContentEffect.Stroke(strokeStyle))
    }
}
