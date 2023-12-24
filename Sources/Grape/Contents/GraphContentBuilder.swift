import SwiftUI

public final class PartialGraphMark<NodeID: Hashable>: GraphContent & GraphProtocol {
    @usableFromInline var nodes: [NodeMark<NodeID>]
    @usableFromInline var links: [LinkMark<NodeID>]

    @inlinable
    init(nodes: [NodeMark<NodeID>], links: [LinkMark<NodeID>]) {
        self.nodes = nodes
        self.links = links
    }

    @inlinable
    static var empty: PartialGraphMark<NodeID> {
        return .init(nodes: [], links: [])
    }

    @discardableResult
    @inlinable
    func with(node: NodeMark<NodeID>) -> Self {
        nodes.append(node)
        return self
    }

    @discardableResult
    @inlinable
    func with(link: LinkMark<NodeID>) -> Self {
        links.append(link)
        return self
    }

    @discardableResult
    @inlinable
    func with(partial: PartialGraphMark<NodeID>) -> Self {
        links.append(contentsOf: partial.links)
        nodes.append(contentsOf: partial.nodes)
        return self
    }

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        links.forEach { $0._attachToGraphRenderingContext(&context) }
        nodes.forEach { $0._attachToGraphRenderingContext(&context) }
    }

}

public struct FullyConnected<NodeID: Hashable>: GraphContent {

    public var connectedPartial: PartialGraphMark<NodeID>

    @inlinable
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

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        connectedPartial._attachToGraphRenderingContext(&context)
    }
}

@resultBuilder
public struct GraphContentBuilder<NodeID: Hashable> {

    public typealias Link = LinkMark<NodeID>
    public typealias Node = NodeMark<NodeID>
    public typealias PartialGraph = PartialGraphMark<NodeID>

    public static func buildPartialBlock<T: GraphContent>(first content: T) -> some GraphContent<NodeID> where T.NodeID == NodeID {
        return content
    }

    public static func buildPartialBlock<T1, T2>(accumulated: T1, next: T2) -> some GraphContent<NodeID> where T1: GraphContent, T2: GraphContent, T1.NodeID == NodeID, T2.NodeID == NodeID {
        return _PairedGraphContent(accumulated, next)
    }

    public static func buildBlock() -> some GraphContent<NodeID> {
        return _EmptyGraphContent()
    }


    // public static func buildExpression(_ expression: Node) -> Node {
    //     return expression
    // }

    // public static func buildExpression(_ expression: Link) -> Link {
    //     return expression
    // }

    // public static func buildExpression(_ expression: FullyConnected<NodeID>) -> PartialGraph {
    //     return expression.connectedPartial
    // }

    // public static func buildExpression<T>(_ expression: T) -> T where T: GraphContent {
    //     return expression
    // }

    // public static func buildExpression<D, ID, GC>(
    //     _ expression: ForEach<D, ID, GraphContentWrapper<GC>>
    // ) -> ForEach<D, ID, GraphContentWrapper<GC>>
    // where GC: GraphContent, GC.NodeID == NodeID {
    //     return expression
    // }

    public static func buildArray<T>(_ components: [T]) -> some GraphContent<NodeID> where T: GraphContent, T.NodeID == NodeID {
        return _ArrayGraphContent(components)
    }

    // public static func buildExpression(
    //     @GraphContentBuilder<NodeID> expression: () -> PartialGraphMark<NodeID>
    // ) -> PartialGraph {
    //     return PartialGraph.empty
    // }

}
