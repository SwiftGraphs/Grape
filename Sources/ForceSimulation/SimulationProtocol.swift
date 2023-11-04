public protocol SimulationProtocol {
    associatedtype CompositedForce: ForceProtocol
    associatedtype NodeID: Hashable
    associatedtype V: SIMD where V.Scalar: FloatingPoint

    var nodeIds: [NodeID] { get set }
    var state: Dimension<NodeID, V>.PhysicalState { get }

    @Dimension<NodeID, V>.ForceBuilder
    var field: CompositedForce { get }
}