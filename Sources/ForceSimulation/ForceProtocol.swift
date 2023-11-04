public protocol ForceProtocol {
    associatedtype NodeID: Hashable
    associatedtype V: SIMD where V.Scalar: FloatingPoint

    func apply()
    func bind<S: SimulationProtocol>(_ simulation: S) where S.NodeID == NodeID, S.V == V
}
