import SwiftUI

public enum StrokeColor: Equatable, Hashable {
    case clip
    case color(Color)
}

extension GraphContentEffect {
    @usableFromInline
    internal struct Stroke: Equatable, Hashable {

        // @usableFromInline
        // let shading: GraphicsContext.Shading
        @usableFromInline
        let color: StrokeColor

        @usableFromInline
        let style: StrokeStyle?

        @inlinable
        public init(
            // _ shading: GraphicsContext.Shading,
            _ color: StrokeColor = .clip,
            _ style: StrokeStyle? = nil
        ) {
            self.color = color
            self.style = style
        }

        @inlinable
        public func hash(into hasher: inout Hasher) {
            hasher.combine(color)
            if let style {
                hasher.combine(style.lineWidth)
                hasher.combine(style.lineCap)
                hasher.combine(style.lineJoin)
                hasher.combine(style.miterLimit)
                hasher.combine(style.dash)
                hasher.combine(style.dashPhase)
            }
        }
    }
}

extension GraphContentEffect.Stroke: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {
        context.states.stroke.append(self)
    }

    @inlinable
    public func _exit<NodeID>(_ context: inout _GraphRenderingContext<NodeID>)
    where NodeID: Hashable {
        context.states.stroke.removeLast()
    }
}
