public struct _GraphRenderingContext<NodeID: Hashable>: Equatable {

    @usableFromInline var nodes: [NodeMark<NodeID>] = []
    @usableFromInline var edges: [LinkMark<NodeID>] = []

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
