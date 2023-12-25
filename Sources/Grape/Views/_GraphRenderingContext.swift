public struct _GraphRenderingContext<NodeID: Hashable>: Equatable {

    @usableFromInline var nodes: [NodeMark<NodeID>] = []
    @usableFromInline var edges: [LinkMark<NodeID>] = []

    @usableFromInline
    enum NodeRenderingOperation: Equatable {
        case node(NodeMark<NodeID>)
        case modifierBegin(AnyGraphContentModifier)
        case modifierEnd
    }

    @usableFromInline
    enum EdgeRenderingOperation: Equatable {
        case edge(LinkMark<NodeID>)
        case modifierBegin(AnyGraphContentModifier)
        case modifierEnd
    }

    @usableFromInline
    var operations: [NodeRenderingOperation] = []

    @usableFromInline
    var edgeOperations: [EdgeRenderingOperation] = []

    @inlinable
    init() {

    }

    @inlinable
    mutating func appendNode(_ node: NodeMark<NodeID>) {
        nodes.append(node)
    }

    @inlinable
    mutating func appendEdge(_ edge: LinkMark<NodeID>) {
        edges.append(edge)
    }

}
