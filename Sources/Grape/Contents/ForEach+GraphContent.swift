import SwiftUI

public struct GraphContentWrapper<InnerGraphContent>: GraphContent
where InnerGraphContent: GraphContent {
    public typealias NodeID = InnerGraphContent.NodeID

    @usableFromInline
    let storage: InnerGraphContent

    @inlinable
    init(_ content: InnerGraphContent) {
        self.storage = content
    }

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        storage._attachToGraphRenderingContext(&context)
    }
}

extension GraphContentWrapper: View {
    public var body: some View {
        EmptyView()
    }

    @inlinable
    static func pullback<T>(_ content: @escaping (T) -> InnerGraphContent) -> (T) -> Self {
        return { element in
            return .init(content(element))
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

extension ForEach where ID == Data.Element.ID, Content: View, Data.Element: Identifiable {

    public init<NodeID, IG>(
        data: Data,
        @GraphContentBuilder<NodeID> content: @escaping (Data.Element) -> IG
    )
    where
        IG: GraphContent<NodeID>,
        NodeID: Hashable,
        Content == GraphContentWrapper<IG>
    {
        let pb = GraphContentWrapper.pullback(content)
        self.init(data, content: pb)
    }

}

struct ID: Identifiable {
    var id: Int
}

func buildGraph<NodeID>(
    @GraphContentBuilder<NodeID> _ builder: () -> some GraphContent<NodeID>
) -> some GraphContent where NodeID: Hashable {
    let result = builder()
    return result
}

func testForEach() {
    let arr = [
        ID(id: 0),
        ID(id: 1),
        ID(id: 2),
    ]

    let a = ForEach(data: arr) { i in
        NodeMark(id: i.id)
    }

    

    let _ = buildGraph {
        NodeMark(id: 0)
        ForEach(data: arr) { i in
            NodeMark(id: i.id)
        }
    }
}
