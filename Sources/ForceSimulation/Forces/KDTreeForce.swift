protocol KDTreeForce<Vector>: ForceProtocol
where
    Vector: SimulatableVector & L2NormCalculatable
{
    associatedtype Delegate: KDTreeDelegate where Delegate.Vector == Vector, Delegate.NodeID == Int

    var tree: KDTree<Vector, Delegate> { get set }
    
    func buildTree()
}

struct CompositedKDTreeDelegate<V, D1, D2>: KDTreeDelegate
where
    V: SimulatableVector & L2NormCalculatable,
    D1: KDTreeDelegate<Int, V>, D2: KDTreeDelegate<Int, V>
{
    var d1: D1
    var d2: D2

    mutating func didAddNode(_ node: Int, at position: V) {
        d1.didAddNode(node, at: position)
        d2.didAddNode(node, at: position)
    }

    mutating func didRemoveNode(_ node: Int, at position: V) {
        d1.didRemoveNode(node, at: position)
        d2.didRemoveNode(node, at: position)
    }

    func spawn() -> CompositedKDTreeDelegate<V, D1, D2> {
        return .init(d1: d1.spawn(), d2: d2.spawn())
    }

}

// public struct CompositedKDTreeForce<Vector, KF1, KF2>: ForceProtocol
// where
//     KF1: KDTreeForce<Vector>, KF2: ForceProtocol<Vector>,
//     Vector: SimulatableVector & L2NormCalculatable,
//     KF1.Vector == Vector, KF2.Vector == Vector, KF1.Vector == Vector
// {
// }
