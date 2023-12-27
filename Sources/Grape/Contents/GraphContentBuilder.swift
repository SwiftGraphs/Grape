@resultBuilder
public struct GraphContentBuilder<NodeID: Hashable> {

    public typealias Content = GraphContent<NodeID>
    @inlinable
    public static func buildPartialBlock<T: GraphContent>(first content: T) -> T
    where T.NodeID == NodeID {
        return content
    }
    @inlinable
    public static func buildPartialBlock<T1, T2>(accumulated: T1, next: T2) -> some Content
    where T1: Content, T2: Content, T1.NodeID == NodeID, T2.NodeID == NodeID, T1.NodeID == T2.NodeID
    {
        return _PairedGraphContent(accumulated, next)
    }
    @inlinable
    public static func buildBlock() -> some Content {
        return _EmptyGraphContent()
    }

    @inlinable
    public static func buildArray<T>(_ components: [T]) -> some Content
    where T: Content, T.NodeID == NodeID {
        return _ArrayGraphContent(components)
    }

    // Opaque breaks type inference?    
    @inlinable
    public static func buildEither<T1, T2>(first component: T1) -> _ConditionalGraphContent<T1, T2>
    where T1: Content, T1.NodeID == NodeID, T2: Content, T2.NodeID == NodeID {
        return _ConditionalGraphContent<T1, T2>(.trueContent(component))
    }

    @inlinable
    public static func buildEither<T1, T2>(second component: T2) -> _ConditionalGraphContent<T1, T2>
    where T1: Content, T1.NodeID == NodeID, T2: Content, T2.NodeID == NodeID {
        return _ConditionalGraphContent<T1, T2>(.falseContent(component))
    }

    @inlinable
    public static func buildLimitedAvailability<T>(_ component: T?) -> some Content
    where T: Content, T.NodeID == NodeID {
        return _OptionalGraphContent(component)
    }
    
    @inlinable
    public static func buildIf<T>(_ component: T?) -> some Content
    where T: Content, T.NodeID == NodeID {
        return _OptionalGraphContent(component)
    }

    @inlinable
    public static func buildExpression<T>(_ expression: T) -> T
    where T: Content, T.NodeID == NodeID {
        return expression
    }
}
