/// A Hashable identifier for an edge.
///
/// It’s a utility type for preserving `Hashable` conformance.
public struct EdgeID<NodeID: Hashable>: Hashable {
    public var source: NodeID
    public var target: NodeID

    public init(source: NodeID, target: NodeID) {
        self.source = source
        self.target = target
    }
}
