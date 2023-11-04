public protocol ForceProtocol {
    associatedtype NodeID: Hashable
    associatedtype V: SIMD where V.Scalar: FloatingPoint

    func apply()
    func bind<S: SimulationProtocol>(_ simulation: S) where S.NodeID == NodeID, S.V == V
}

public protocol ForceComposition {
    associatedtype NodeID: Hashable
    associatedtype V: SIMD where V.Scalar: FloatingPoint
    associatedtype Composition: ForceProtocol

    @Dimension<NodeID, V>.ForceBuilder
    var composition: Composition { get }
}


