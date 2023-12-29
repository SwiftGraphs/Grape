import SwiftUI

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
