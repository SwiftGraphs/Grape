public enum AttributeDescriptor<T> {
    case varied((Int) -> T)
    case constant(T)
}

extension AttributeDescriptor {
    @inlinable
    func calculate(for count: Int) -> [T] {
        switch self {
        case .constant(let m):
            return [T](repeating: m, count: count)
        case .varied(let radiusProvider):
            return (0..<count).map(radiusProvider)
        }
    }
}


public struct EdgeID<NodeID: Hashable>: Hashable {
    public var source: NodeID
    public var target: NodeID
}