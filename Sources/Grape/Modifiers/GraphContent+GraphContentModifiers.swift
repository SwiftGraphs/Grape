import SwiftUI

#if canImport(Charts)
    import Charts
#endif

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

    #if canImport(Charts)
        @inlinable
        public func symbol(_ shape: BasicChartSymbolShape) -> some GraphContent<NodeID> {
            return ModifiedGraphContent(self, GraphContentEffect.Symbol(shape))
        }
    #endif

    @inlinable
    public func symbolSize(_ size: CGSize) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GraphContentEffect.SymbolSize(size))
    }

    @inlinable
    public func symbolSize(_ size: SIMD2<Double>) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GraphContentEffect.SymbolSize(size.cgSize))
    }

    @inlinable
    public func symbolSize(radius: CGFloat) -> some GraphContent<NodeID> {
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
    public func label(
        _ text: Text?, alignment: Alignment = .bottom, offset: CGVector = .zero
    ) -> some GraphContent<NodeID> {

        return ModifiedGraphContent(
            self, GraphContentEffect.Label(text, alignment: alignment, offset: offset))
    }

    @inlinable
    public func label(
        _ text: Text?, alignment: Alignment = .bottom, offset: SIMD2<Double> = .zero
    ) -> some GraphContent<NodeID> {

        return label(text, alignment: alignment, offset: offset.cgVector)
    }

    @inlinable
    public func label(
        _ string: String?, alignment: Alignment = .bottom, offset: CGVector = .zero
    ) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(
            self, GraphContentEffect.Label(nil, alignment: alignment, offset: offset))
    }

    @inlinable
    public func label(
        _ string: String?, alignment: Alignment = .bottom, offset: SIMD2<Double> = .zero
    ) -> some GraphContent<NodeID> {
        return label(string, alignment: alignment, offset: offset.cgVector)
    }

    @inlinable
    public func label(
        _ alignment: Alignment = .bottom, offset: CGVector = .zero,
        @ViewBuilder _ content: () -> Text?
    ) -> some GraphContent<NodeID> {

        return ModifiedGraphContent(
            self, GraphContentEffect.Label(content(), alignment: alignment, offset: offset))
    }

    @inlinable
    public func label(
        alignment: Alignment = .bottom, offset: SIMD2<Double> = .zero,
        @ViewBuilder _ content: () -> Text?
    ) -> some GraphContent<NodeID> {
        return label(alignment, offset: offset.cgVector, content)
    }

    @inlinable
    public func richLabel(
        _ tag: String,
        _ alignment: Alignment = .bottom,
        offset: CGVector = .zero,
        @ViewBuilder _ content: () -> some View
    ) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(
            self, GraphContentEffect.RichLabel(tag, content(), alignment: alignment, offset: offset)
        )
    }

    @inlinable
    public func richLabel(
        _ tag: String,
        alignment: Alignment = .bottom,
        offset: SIMD2<Double> = .zero,
        @ViewBuilder _ content: () -> some View
    ) -> some GraphContent<NodeID> {
        return richLabel(tag, alignment, offset: offset.cgVector, content)
    }

    /// Sets the stroke style for this graph content.
    ///
    /// - When a `.clip` color is applied to node marks, the stroke color of the symbol
    ///   will be **the same as the background (cliped to transparent).**
    /// - When a `.clip` color is applied to link marks, the stroke will not be drawn.
    /// - When a `nil` stroke style is applied to node marks, the stroke style will be the same as the default stroke style.
    @inlinable
    public func stroke(
        _ color: StrokeColor = .clip,
        _ strokeStyle: StrokeStyle? = nil
    ) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(
            self, GraphContentEffect.Stroke(color, strokeStyle))
    }

    @inlinable
    public func stroke(
        _ color: Color,
        _ strokeStyle: StrokeStyle? = nil
    ) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(
            self, GraphContentEffect.Stroke(.color(color), strokeStyle))
    }

    @inlinable
    public func linkShape(
        _ shape: some LinkShape
    ) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GraphContentEffect._LinkShape(shape))
    }
    
}
