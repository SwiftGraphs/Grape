import SwiftUI

public struct _GraphContentWrapper<InnerGraphContent>: GraphContent
where InnerGraphContent: GraphContent {
    public typealias NodeID = InnerGraphContent.NodeID

    public let storage: InnerGraphContent

    @inlinable
    init(_ content: InnerGraphContent) {
        self.storage = content
    }

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        storage._attachToGraphRenderingContext(&context)
    }
}

public protocol _GraphContentWrappingView: View {
    associatedtype InnerGraphContent: GraphContent
    @inlinable
    var storage: InnerGraphContent { get }
}

extension _GraphContentWrapper: _GraphContentWrappingView {
    @inlinable
    public var body: some View {
        EmptyView()
    }

    @inlinable
    internal static func pullback<T>(_ content: @escaping (T) -> InnerGraphContent) -> (T) -> Self {
        return { element in
            return .init(content(element))
        }
    }

    @inlinable
    internal static func pullback<T, ID>(
        id: KeyPath<T, ID>, _ content: @escaping (ID) -> InnerGraphContent
    )
        -> (T) -> Self where ID: Hashable
    {
        return { element in
            return .init(content(element[keyPath: id]))
        }
    }
}

extension ForEach: GraphContent where Content: GraphContent {
    public typealias NodeID = Content.NodeID

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        self.data.forEach { element in
            self.content(element)._attachToGraphRenderingContext(&context)
        }
    }
}

extension ForEach
where ID == Data.Element.ID, Content: _GraphContentWrappingView, Data.Element: Identifiable {
    @inlinable
    @_disfavoredOverload
    public init<NodeID, IG>(
        _ data: Data,
        @GraphContentBuilder<NodeID> graphContent: @escaping (Data.Element) -> IG
    )
    where
        IG: GraphContent<NodeID>,
        NodeID: Hashable,
        Content == _GraphContentWrapper<IG>
    {
        let pb = _GraphContentWrapper.pullback(graphContent)
        self.init(data, content: pb)
    }
}

extension ForEach where Content: _GraphContentWrappingView {
    @inlinable
    public init<NodeID, IG>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @GraphContentBuilder<NodeID> graphContent: @escaping (ID) -> IG
    )
    where
        IG: GraphContent<NodeID>,
        NodeID: Hashable,
        Content == _GraphContentWrapper<IG>,
        ID: Hashable
    {
        let pb = _GraphContentWrapper.pullback(id: id, graphContent)
        self.init(data, id: id, content: pb)
    }

}

// extension ForEach {
//     @inlinable
//     public init<NodeID, IG>(
//         _ range: Range<Int>,
//         @GraphContentBuilder<NodeID> content: @escaping (Int) -> IG
//     )
//     where
//         Data == Swift.Range<Swift.Int>, ID == Swift.Int, IG: GraphContent<NodeID>, NodeID: Hashable,
//         Content == _GraphContentWrapper<IG>
//     {
//         self.init(range, id: \.self, content: _GraphContentWrapper.pullback(content))
//     }
// }

extension ForEach
where
    Data == Swift.Range<Swift.Int>, ID == Swift.Int, Content: _GraphContentWrappingView
{
    @inlinable
    public init<RawData, NodeID, IG>(
        _ data: RawData,
        @GraphContentBuilder<NodeID> graphContent: @escaping (RawData.Element) -> IG
    )
    where
        IG: GraphContent<NodeID>, NodeID: Hashable,
        RawData: RandomAccessCollection,
        RawData.Indices == Swift.Range<Swift.Int>,
        Content == _GraphContentWrapper<IG>
    {

        self.init(data.indices, id: \.self) { index in
            graphContent(data[index])
        }
    }
}
