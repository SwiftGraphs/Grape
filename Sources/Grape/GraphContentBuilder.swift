public final class PartialGraphMark<NodeID: Hashable>: GraphContent {
    var nodes: [NodeMark<NodeID>]
    var links: [LinkMark<NodeID>]

    init(nodes: [NodeMark<NodeID>], links: [LinkMark<NodeID>]) {
        self.nodes = nodes
        self.links = links
    }

    static var empty: PartialGraphMark<NodeID> {
        return .init(nodes: [], links: [])
    }

    @discardableResult
    func with(node: NodeMark<NodeID>) -> Self {
        nodes.append(node)
        return self
    }

    @discardableResult
    func with(link: LinkMark<NodeID>) -> Self {
        links.append(link)
        return self
    }

    @discardableResult
    func with(partial: PartialGraphMark<NodeID>) -> Self {
        links.append(contentsOf: partial.links)
        nodes.append(contentsOf: partial.nodes)
        return self
    }
}

public struct FullyConnected<NodeID: Hashable>: GraphContent {
    public var connectedPartial: PartialGraphMark<NodeID>
    public init(@GraphContentBuilder<NodeID> builder: () -> PartialGraphMark<NodeID>) {
        let result = builder()
        result.links = []
        for i in result.nodes.indices {
            for j in i + 1..<result.nodes.count {
                result.links.append(
                    LinkMark<NodeID>(from: result.nodes[i].id, to: result.nodes[j].id))
            }
        }
        connectedPartial = result
    }
}

@resultBuilder
public struct GraphContentBuilder<NodeID: Hashable> {

    public typealias Link = LinkMark<NodeID>
    public typealias Node = NodeMark<NodeID>
    public typealias PartialGraph = PartialGraphMark<NodeID>

    public static func buildPartialBlock(first content: Node) -> PartialGraph {
        return PartialGraph(nodes: [content], links: [])
    }

    public static func buildPartialBlock(first content: Link) -> PartialGraph {
        return PartialGraph(nodes: [], links: [content])
    }

    public static func buildPartialBlock(accumulated: PartialGraph, next: Link) -> PartialGraph {
        return accumulated.with(link: next)
    }

    public static func buildPartialBlock(accumulated: PartialGraph, next: Node) -> PartialGraph {
        return accumulated.with(node: next)
    }

    public static func buildPartialBlock(accumulated: PartialGraph, next: PartialGraph) -> PartialGraph {
        return accumulated.with(partial: next)
    }

    public static func buildBlock() -> PartialGraph {
        return PartialGraph.empty
    }

    public static func buildExpression(_ expression: (NodeID, NodeID)) -> Link {
        return Link(from: expression.0, to: expression.1)
    }

    public static func buildExpression(_ expression: Node) -> Node {
        return expression
    }

    public static func buildExpression(_ expression: Link) -> Link {
        return expression
    }

    public static func buildExpression(_ expression: FullyConnected<NodeID>) -> PartialGraph {
        return expression.connectedPartial
    }

    public static func buildArray(_ components: [PartialGraph]) -> PartialGraph {
        let partial = PartialGraph(nodes: [], links: [])
        for expr in components {
            partial.with(partial: expr)
        }
        return partial
    }

    public static func buildExpression(
        @GraphContentBuilder<NodeID> expression: () -> PartialGraphMark<NodeID>
    ) -> PartialGraph {
        return PartialGraph.empty
    }

}
