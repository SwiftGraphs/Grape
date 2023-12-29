import SwiftUI

@usableFromInline
internal enum RenderOperation<NodeID: Hashable> {
    @usableFromInline
    struct Node {
        @usableFromInline
        let mark: NodeMark<NodeID>
        @usableFromInline
        let fill: GraphicsContext.Shading?
        @usableFromInline
        let stroke: StrokeStyle?
        @usableFromInline
        let path: ((SIMD2<Double>) -> Path)?

        @inlinable
        init(
            _ mark: NodeMark<NodeID>,
            _ fill: GraphicsContext.Shading?,
            _ stroke: StrokeStyle?,
            _ path: ((SIMD2<Double>) -> Path)?
        ) {
            self.mark = mark
            self.fill = fill
            self.stroke = stroke
            self.path = path
        }
    }

    @usableFromInline
    struct Link {
        @usableFromInline
        let mark: LinkMark<NodeID>
        @usableFromInline
        let fill: GraphicsContext.Shading?
        @usableFromInline
        let stroke: StrokeStyle?
        @usableFromInline
        let path: ((SIMD2<Double>, SIMD2<Double>) -> Path)?

        @inlinable
        init(
            _ mark: LinkMark<NodeID>,
            _ fill: GraphicsContext.Shading?,
            _ stroke: StrokeStyle?,
            _ path: ((SIMD2<Double>, SIMD2<Double>) -> Path)?
        ) {
            self.mark = mark
            self.fill = fill
            self.stroke = stroke
            self.path = path
        }
    }
}

extension RenderOperation.Node: Equatable {
    @inlinable
    internal static func == (lhs: Self, rhs: Self) -> Bool {
        let fillEq = lhs.fill == nil && rhs.fill == nil
        let pathEq = lhs.path == nil && rhs.path == nil
        return lhs.mark == rhs.mark
            && fillEq
            && lhs.stroke == rhs.stroke
            && pathEq
    }
}

extension RenderOperation.Link: Equatable {
    @inlinable
    internal static func == (lhs: Self, rhs: Self) -> Bool {
        let fillEq = lhs.fill == nil && rhs.fill == nil
        let pathEq = lhs.path == nil && rhs.path == nil
        return lhs.mark == rhs.mark
            && fillEq
            && lhs.stroke == rhs.stroke
            && pathEq
    }
}

@usableFromInline
internal enum RenderingOperation<NodeID: Hashable> {
    case node(
        NodeMark<NodeID>,
        GraphicsContext.Shading?,
        StrokeStyle?,
        ((SIMD2<Double>) -> Path)?
    )
    case link(
        LinkMark<NodeID>,
        GraphicsContext.Shading?,
        StrokeStyle?,
        ((SIMD2<Double>, SIMD2<Double>) -> Path)?
    )
    case label(Text, id: GraphRenderingStates<NodeID>.StateID)

    // case updateShading(GraphicsContext.Shading)

    // case updateStroke(GraphContentEffect.Stroke)

    // case updateOpacity(Double)

    // @available(*, deprecated, message: "Use `updateShading` instead.")
    // case modifierBegin(AnyGraphContentModifier)

    // case modifierEnd
}

extension RenderingOperation: Equatable {
    @inlinable
    internal static func == (lhs: Self, rhs: Self) -> Bool {
        return false
        // switch (lhs, rhs) {
        // case (.node(let l), .node(let r)):
        //     return l == r
        // case (.link(let l), .link(let r)):
        //     return l == r
        // case (.modifierEnd, .modifierEnd):
        //     return true
        // case (.modifierBegin(let l), .modifierBegin(let r)):
        //     return l == r
        // default:
        //     return false
        // }
    }
}
