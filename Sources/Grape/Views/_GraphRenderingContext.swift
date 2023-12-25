public struct _GraphRenderingContext<NodeID: Hashable>: Equatable {

    // @usableFromInline var nodes: [NodeMark<NodeID>] = []
    // @usableFromInline var edges: [LinkMark<NodeID>] = []

    @usableFromInline
    enum RenderingOperation {
        case node(NodeMark<NodeID>)
        case link(LinkMark<NodeID>)
        case modifierBegin(AnyGraphContentModifier)
        case modifierEnd
    }

    @usableFromInline
    var operations: [RenderingOperation] = []

    @inlinable
    init() {

    }

    @inlinable
    func renderGraphContent() {

    }


}

extension _GraphRenderingContext.RenderingOperation: Equatable {
    @inlinable
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.node(let l), .node(let r)):
            return l == r
        case (.link(let l), .link(let r)):
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

extension _GraphRenderingContext {
    @inlinable
    var nodes: [NodeMark<NodeID>] {
        var nodes: [NodeMark<NodeID>] = []
        for operation in operations {
            switch operation {
            case .node(let node):
                nodes.append(node)
            default:
                break
            }
        }
        return nodes
    }

    @inlinable
    var edges: [LinkMark<NodeID>] {
        var edges: [LinkMark<NodeID>] = []
        for operation in operations {
            switch operation {
            case .link(let edge):
                edges.append(edge)
            default:
                break
            }
        }
        return edges
    }
}
