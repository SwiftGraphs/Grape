extension Force {

    /// A force that does nothing.
    /// This is a helper for creating a force tipe.
    public struct EmptyForce<NodeID, V>: ForceProtocol
    where NodeID: Hashable, V: VectorLike, V.Scalar: SimulatableFloatingPoint {
        @inlinable public func apply() {}
        @inlinable public init() {}
        @inlinable public func bindSimulation(_ simulation: SimulationState<NodeID, V>?) {}
    }

}
