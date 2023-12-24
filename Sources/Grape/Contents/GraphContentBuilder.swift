import Charts
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
    public typealias Content = GraphContent<NodeID>

    public static func buildPartialBlock<T: GraphContent>(first content: T) -> T
    where T.NodeID == NodeID {
        return content
    }

    public static func buildPartialBlock<T1, T2>(accumulated: T1, next: T2) -> some Content
    where T1: Content, T2: Content, T1.NodeID == NodeID, T2.NodeID == NodeID, T1.NodeID == T2.NodeID
    {
        return _PairedGraphContent(accumulated, next)
    }

    public static func buildBlock() -> some Content {
        return _EmptyGraphContent()
    }

    public static func buildArray<T>(_ components: [T]) -> some Content
    where T: Content, T.NodeID == NodeID {
        return _ArrayGraphContent(components)
    }

    // Opaque breaks type inference?
    public static func buildEither<T1, T2>(first component: T1) -> _ConditionalGraphContent<T1, T2>
    where T1: Content, T1.NodeID == NodeID, T2: Content, T2.NodeID == NodeID {
        return _ConditionalGraphContent<T1, T2>(.trueContent(component))
    }

    public static func buildEither<T1, T2>(second component: T2) -> _ConditionalGraphContent<T1, T2>
    where T1: Content, T1.NodeID == NodeID, T2: Content, T2.NodeID == NodeID {
        return _ConditionalGraphContent<T1, T2>(.falseContent(component))
    }

    public static func buildLimitedAvailability<T>(_ component: T?) -> some Content
    where T: Content, T.NodeID == NodeID {
        return _OptionalGraphContent(component)
    }

    public static func buildIf<T>(_ component: T?) -> some Content
    where T: Content, T.NodeID == NodeID {
        return _OptionalGraphContent(component)
    }

    public static func buildExpression<T>(_ expression: T) -> T
    where T: Content, T.NodeID == NodeID {
        return expression
    }
}
