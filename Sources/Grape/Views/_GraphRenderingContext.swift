public struct _GraphRenderingContext<NodeID: Hashable>: Equatable {

    @usableFromInline var nodes: [NodeMark<NodeID>] = []
    @usableFromInline var edges: [LinkMark<NodeID>] = []

    @usableFromInline
    enum RenderingOperation {
        case node(NodeMark<NodeID>)
        case edge(LinkMark<NodeID>)
        case modifierBegin(AnyGraphContentModifier)
        case modifierEnd
    }

    @usableFromInline
    var operations: [RenderingOperation] = []

    @inlinable
    init() {

    }


}

extension _GraphRenderingContext.RenderingOperation: Equatable {
    @inlinable
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.node(let l), .node(let r)):
            return l == r
        case (.edge(let l), .edge(let r)):
            return l == r
        case (.modifierBegin(let l), .modifierBegin(let r)):
            return l == r
        case (.modifierEnd, .modifierEnd):
            return true
        default:
            return false
        }
    }
}
