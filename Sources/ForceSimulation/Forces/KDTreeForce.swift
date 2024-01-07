// public protocol KDTreeForce<Vector>: ForceProtocol
// where
//     Vector: SimulatableVector & L2NormCalculatable
// {
//     associatedtype Delegate: KDTreeDelegate where Delegate.Vector == Vector, Delegate.NodeID == Int

//     var kinetics: Kinetics<Vector>! { get set }

//     func epilogue()
//     func buildDelegate() -> Delegate
//     func visitForeignTree<D: KDTreeDelegate>(
//         tree: inout KDTree<Vector, D>, getDelegate: (D) -> Delegate)
// }

// public struct CompositedKDTreeDelegate<V, D1, D2>: KDTreeDelegate
// where
//     V: SimulatableVector & L2NormCalculatable,
//     D1: KDTreeDelegate<Int, V>, D2: KDTreeDelegate<Int, V>
// {
//     var d1: D1
//     var d2: D2

//     mutating public func didAddNode(_ node: Int, at position: V) {
//         d1.didAddNode(node, at: position)
//         d2.didAddNode(node, at: position)
//     }

//     mutating public func didRemoveNode(_ node: Int, at position: V) {
//         d1.didRemoveNode(node, at: position)
//         d2.didRemoveNode(node, at: position)
//     }

//     public func spawn() -> CompositedKDTreeDelegate<V, D1, D2> {
//         return .init(d1: d1.spawn(), d2: d2.spawn())
//     }

// }

// extension Kinetics.ManyBodyForce: KDTreeForce {
//     public typealias Delegate = MassCentroidKDTreeDelegate<Vector>

//     public func epilogue() {

//     }

//     public func buildDelegate() -> MassCentroidKDTreeDelegate<Vector> {
//         return .init(massProvider: { self.precalculatedMass[$0] })
//     }

//     public func visitForeignTree<D: KDTreeDelegate>(
//         tree: inout KDTree<Vector, D>, getDelegate: (D) -> MassCentroidKDTreeDelegate<Vector>
//     ) {
        
//     }
// }

// extension Kinetics.CollideForce: KDTreeForce {
//     public typealias Delegate = MaxRadiusNDTreeDelegate<Vector>

//     public func epilogue() {

//     }

//     public func buildDelegate() -> MaxRadiusNDTreeDelegate<Vector> {
//         return .init(radiusProvider: { self.calculatedRadius[$0] })
//     }

//     public func visitForeignTree<D>(
//         tree: inout KDTree<Vector, D>, getDelegate: (D) -> MaxRadiusNDTreeDelegate<Vector>
//     ) where D: KDTreeDelegate, Vector == D.Vector, D.NodeID == Int {

//     }
// }

// public struct CompositedKDTreeForce<Vector, KF1, KF2>: ForceProtocol
// where
//     KF1: KDTreeForce<Vector>, KF2: KDTreeForce<Vector>,
//     Vector: SimulatableVector & L2NormCalculatable,
//     KF1.Vector == Vector, KF2.Vector == Vector, KF1.Vector == Vector
// {
//     var force1: KF1
//     var force2: KF2

//     public func apply() {
//         force1.epilogue()
//         force2.epilogue()

//         var tree = KDTree<Vector, CompositedKDTreeDelegate<Vector, KF1.Delegate, KF2.Delegate>>(
//             covering: force1.kinetics!.position,
//             rootDelegate: CompositedKDTreeDelegate(
//                 d1: force1.buildDelegate(),
//                 d2: force2.buildDelegate()
//             )
//         )

//         force1.visitForeignTree(tree: &tree, getDelegate: \.d1)
//         force2.visitForeignTree(tree: &tree, getDelegate: \.d2)
//     }

//     public mutating func bindKinetics(_ kinetics: Kinetics<Vector>) {

//     }

// }
